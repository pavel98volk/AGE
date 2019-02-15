from gameEnvironment import GameEnvironment
from gameObject import GameObject
from simpleMovingGameObject import SimpleMovingGameObject
from map2DGameEnvironment import Map2DGameEnvironment
import xml.etree.ElementTree

class GameLauncher:
    rootElement=None
    time=0
    log=[]
    def gameObjImportHelper(self,el):
        value = GameObject(props = el.attrib)
        for child in el:
            if child.tag=='outerProps':
                for prop in child:
                    value.addOuterProp(prop.attrib['name'],self.getPropValue(prop));
        return value

    def simpleMovingGameObjectImportHelper(self,el):
        value = SimpleMovingGameObject(props=el.attrib);
        for child in el:
            if child.tag=='outerProps':
                for prop in child:
                    value.addOuterProp(prop.attrib['name'],self.getPropValue(prop));
        return value

    def getPropValue(self,el):
        if el.attrib['type']=='string':
            return el.attrib['value']
        elif el.attrib['type']=='number':
            return int(el.attrib['value'])

    def gameEnvImportHelper(self,el):
        value = GameEnvironment(props = el.attrib);
        for child in el:
            if child.tag=='outerProps':
                for prop in child:
                    value.addOuterProp(prop.attrib['name'],self.getPropValue(prop));
            elif child.tag=='inside':
                for inner in child:
                    value.addChild(self.envImportHelper(inner))
        return value
    def map2DGameEnvironmnetImportHelper(self,el):
        value = Map2DGameEnvironment(props = el.attrib);
        for child in el:
            if child.tag=='outerProps':
                for prop in child:
                    value.addOuterProp(prop.attrib['name'],self.getPropValue(prop));
            elif child.tag=='inside':
                for inner in child:
                    value.addChild(self.envImportHelper(inner))
        return value

    def envImportHelper(self,el):
        if el.tag=='GameObject':
            return self.gameObjImportHelper(el)
        elif el.tag=='GameEnvironment':
            return self.gameEnvImportHelper(el)
        elif el.tag=='SimpleMovingGameObject':
            return self.simpleMovingGameObjectImportHelper(el);
        elif el.tag=='Map2DGameEnvironment':
            return self.map2DGameEnvironmnetImportHelper(el);


    def voicesImportHelper(self,voicesEl):
        return {}

    def importFromXML(self,fileName):
        root = xml.etree.ElementTree.parse(fileName).getroot()
        if root.tag == 'model':
            for child in root:
                if child.tag=='environment':
                    if child[0]:
                        self.rootElement = self.envImportHelper(child[0])
                elif child.tag=='voices':
                    self.voices = self.voicesImportHelper(child)
        print(str(self.rootElement.__repr__()));

    def prettyPrint(self,el=None,spaces=''):
        if el==None: el=self.rootElement
        string = spaces+el.__class__.__name__;
        for prop in el.outerState:
            string+=' '+prop+' = '+str(el.outerState[prop]);
        print(string);
        for child in el.getChildren():
            self.prettyPrint(child,spaces+'  ');

    def step(self):
        self.time+=1
        if self.rootElement:
            self.rootElement.update(self.time);
    def launch(self):
        self.time = 0;
        while True:
            self.step();
