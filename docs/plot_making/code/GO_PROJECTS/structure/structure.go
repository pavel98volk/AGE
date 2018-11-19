package main

type PercieveData struct {
	objects    []GObject
	objectData []void
}
type Reasoner interface {
	chooseActions(obj GObject, env Environment, perc PercieveData)
}

type Executor interface {
	execute(obj, env, subj)
}

type ConcreteExecutor struct {
	action_funcs []*func(subj GObject, env Environment, obj GObject)
}

type GObject interface {
	see()
	act()
}
type ConcreteObject interface {
}

func (gb *GObject) act()
