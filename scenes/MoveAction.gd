extends ActionLeaf

export var direction_default : String = "FORWARD"
export var direction_variable : String = "direction"

var move_started = false
var move_completed = false

func tick(actor, blackboard):
	if move_started:
		return RUNNING
	
	if not actor.is_connected("move_completed", self, "_move_completed"):
		actor.connect("move_completed", self, "_move_completed")
		
	if self.move_completed:
		self.move_completed = false
		actor.disconnect("move_completed", self, "_move_completed")
		return SUCCESS

	var direction = blackboard.get(direction_variable, direction_default)

	if not actor.can_move(direction):
		return FAILURE

	move_started = true
	actor.move(direction)

	return RUNNING

func _move_completed():
	if move_started:
		move_started = false
		move_completed = true
