from dataStructures.updateFunctionList import UpdateFunctionList

class GameObject:
    """A class to describe the game Object"""
    innerState={};
    outerState={};
    def getChildren(self):
        return [];

    def __init__(self, props):
        self.outerState ={**self.outerState, **props}
        self.updateList = UpdateFunctionList();
        return
        #print('object inited with props:'+str(props));
    def addOuterProp(self, propName, propValue):
        self.outerState[propName]=propValue

    def update(self, currTime:"currentTime", info:'information from the outside world'={})->'information the objects wants for outside world to know':
        return {"action":"idle"}
