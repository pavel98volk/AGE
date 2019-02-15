

class UpdateFunctionList:
    """A class used to store a list of functions that can be called in a row
    Each function in this case takes as an argument the next function"""
    list = [];

    def execute(self, currTime, info):
        for i in range(0,len(list)):
            info = list[i].onUpdate(currTime,info);
            action={};
            for i in range(len(list)-1,-1,-1):
                action=list[i].onProcessResult(currTime,info,action);
    def insert(self, pos, func):
        self.list.insert(pos,func)
    def delete(self, pos):
        del self.list[pos]
