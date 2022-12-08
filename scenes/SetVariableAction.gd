extends ActionLeaf

export var variable_name : String = "var"
export var variable_value : String = "val"

func tick(_actor, blackboard):
	blackboard.set(variable_name, variable_value)
	return SUCCESS
