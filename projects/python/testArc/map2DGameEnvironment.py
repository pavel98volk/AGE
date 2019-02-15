from gameEnvironment import GameEnvironment
class Map2DGameEnvironment(GameEnvironment):
    def update(self, currTime:"currentTime", info:'information from the outside world'={})->'information the objects wants for outside world to know':
        for child in self.getChildren():
            action = child.update(currTime,{})['action']
            print(child.outerState['name']+ ' chooses '+ action+' action!')
            if action=='up':
                if child.outerState['x']!=None:child.outerState['y']+=1
            elif action=='down':
                if child.outerState['x']!=None:child.outerState['y']-=1
            elif action=='left':
                if child.outerState['x']!=None:child.outerState['x']-=1
            elif action=='right':
                if child.outerState['x']!=None:child.outerState['x']+=1
    
