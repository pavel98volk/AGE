
class UpdateFunction:
  state ={};
  next;
  #unoverridable methods
  def __call__(self, currTime:"currentTime", info:'information from the outside world'={})->'returns the action':
      info = self.onUpdate(info);
      action={};
      if next is not None:
          action = next()
     action = onProcessResult(currTime,info,action);
     return action;
  def changeNext(self, next):
      self.next = next;
# overridable methods;
  def onUpate(self, currTime:"currentTime", info:'information from the outside world'={})->'updated information that\'s passed to the next function':
      return info;
  def onProcessResult(self, currTime,info,action)->'updated action':
      return action;
