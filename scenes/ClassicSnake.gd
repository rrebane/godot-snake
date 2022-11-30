extends Node2D

const ROTATION_STEP = 90
const BLOCK_SIDE_LENGTH = 6

## SCENES ##
var link = preload("res://scenes/SnakeLink.tscn")
onready var head = $Head

## MOVEMENT ##
var head_direction = 0
var direction = Vector2(BLOCK_SIDE_LENGTH, 0)
var direction_as_str = 'RIGHT'
var next_scheduled_move = 'RIGHT'
var snake_parts = []
var cells_visited = []
var tick_interval = 8 # Snake moves every N frames where N is this value

## FRAME COUNTER ##
var i = 0

func _physics_process(_delta):
	if i % tick_interval == 0:
		cells_visited = []
		var previous_head_position = head.position
		cells_visited.append(previous_head_position)
		# This moves the head
		handle_move()

		for n in range(snake_parts.size(), 0, -1):
			var index = n - 1
			if index == 0:
				snake_parts[index].position = previous_head_position 
			else:
				snake_parts[index].position = snake_parts[index-1].position
			cells_visited.append(snake_parts[index].position)
			
		# Check for collision with body
		for p in cells_visited:
			if head.position == p:
				Events.emit_signal("hit")
	i = i + 1


func _input(event):
	# Need to "schedule" this move because I only want to change direction once
	# every N frames where N is tick_interval
	if(event.is_action_pressed("ui_down")):
		next_scheduled_move = 'DOWN'
	if(event.is_action_pressed("ui_up")):
		next_scheduled_move = 'UP'
	if(event.is_action_pressed("ui_left")):
		next_scheduled_move = 'LEFT'
	if(event.is_action_pressed("ui_right")):
		next_scheduled_move = 'RIGHT'

func add_to_snake_parts(pos = head.position):
	var instance = link.instance()
	instance.position = pos
	snake_parts.append(instance)
	add_child(instance)

func handle_move():
	if next_scheduled_move == 'DOWN' and direction_as_str != 'UP':
		direction = Vector2(0, BLOCK_SIDE_LENGTH)
		head.rotation_degrees = 90
		direction_as_str = 'DOWN'
	if next_scheduled_move == 'UP' and direction_as_str != 'DOWN':
		direction = Vector2(0, -BLOCK_SIDE_LENGTH)
		head.rotation_degrees =  -90
		direction_as_str = 'UP'
	if next_scheduled_move == 'LEFT' and direction_as_str != 'RIGHT':
		direction = Vector2(-BLOCK_SIDE_LENGTH, 0)
		head.rotation_degrees = 180
		direction_as_str = 'LEFT'
	if next_scheduled_move == 'RIGHT' and direction_as_str != 'LEFT':
		direction = Vector2(BLOCK_SIDE_LENGTH, 0)
		head.rotation_degrees = 0
		direction_as_str = 'RIGHT'
	var previous_head_position = head.position
	var new_head_position = head.position + direction
	#	Check for walls
	if head.global_position.x < 3 or head.global_position.x > 381:
		Events.emit_signal("hit")
	if head.global_position.y < 3 or head.global_position.y > 211:
		Events.emit_signal("hit")
	# Check for fruit
	if head.check_for_fruit(new_head_position):
		add_to_snake_parts(previous_head_position)
	head.position = new_head_position
