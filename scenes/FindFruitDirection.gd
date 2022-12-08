extends ActionLeaf

func tick(actor, blackboard):
	var direction = actor.fruit_direction()
	
	if direction:
		blackboard.set("fruit_direction", direction)
		return SUCCESS

	return FAILURE
