
from gameObject import GameObject

class SimpleMovingGameObject(GameObject):
    movingFunc=None;
    def getChildren(self):
        return [];
    def __init__(self, props):
        GameObject.__init__(self,props)
        #print('environment created with props:'+str(props))
    def update(self, currTime:"currentTime", info:'information from the outside world'={})->'information the objects wants for outside world to know':
        if self.movingFunc==None:
            self.promptMovingFunc();
        return {"action":eval(self.movingFunc)}
    def promptMovingFunc(self):
        self.movingFunc= input('Enter a logical expression that returns \'up\',\'down\',\'left\' or \'right\'\n '+self.outerState['name']+'(currTime,info)->')
