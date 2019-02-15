from gameObject import GameObject

class GameEnvironment(GameObject):
    inside={'objects':[]}

    def getChildren(self):
        return self.inside['objects'];

    def __init__(self, props):
        GameObject.__init__(self,props)
        #print('environment created with props:'+str(props))
        
    def update(self, currTime:"currentTime", info:'information from the outside world'={})->'information the objects wants for outside world to know':
        for child in self.getChildren():
            child.update(currTime,{});

    def addChild(self, object):
        self.inside['objects'].append(object)
        #print('added child to environment')
