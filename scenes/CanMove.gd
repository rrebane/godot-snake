extends ConditionLeaf

export var direction : String = "FORWARD"

func tick(actor, _blackboard):
	if actor.can_move(direction):
		return SUCCESS
	return FAILURE
