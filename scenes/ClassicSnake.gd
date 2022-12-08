extends Node2D

const ROTATION_STEP = 90
const BLOCK_SIDE_LENGTH = 6

## SCENES ##
var link = preload("res://scenes/SnakeLink.tscn")
onready var head = $Head

## MOVEMENT ##
var head_direction = 0
var direction = Vector2(BLOCK_SIDE_LENGTH, 0)
var current_direction = 'RIGHT'
var next_scheduled_move = 'RIGHT'
var snake_parts = []
var cells_visited = []
var tick_interval = 8 # Snake moves every N frames where N is this value

signal move_completed

## FRAME COUNTER ##
var i = 0

func _ready():
	Events.connect("eat_fruit", self, "add_to_snake_parts")
	
func tick():
	i+= 1

func _physics_process(_delta):
	if i % tick_interval == 0:
		cells_visited = []
		var previous_head_position = head.position
		cells_visited.append(previous_head_position)
		
		move_head()

		var cells_covered_by_body = move_body(snake_parts, previous_head_position)
		check_collision_with_edges(head)
		cells_visited += cells_covered_by_body
		check_collision_with_body(cells_visited, head)
		head.check_for_fruit()
	tick()


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

func add_to_snake_parts(p = head.position):
	var instance = link.instance()
	instance.position = p
	snake_parts.append(instance)
	add_child(instance)

func move_head():
	if next_scheduled_move == 'DOWN' and current_direction != 'UP':
		direction = Vector2(0, BLOCK_SIDE_LENGTH)
		head.rotation_degrees = 90
		current_direction = 'DOWN'
	if next_scheduled_move == 'UP' and current_direction != 'DOWN':
		direction = Vector2(0, -BLOCK_SIDE_LENGTH)
		head.rotation_degrees =  -90
		current_direction = 'UP'
	if next_scheduled_move == 'LEFT' and current_direction != 'RIGHT':
		direction = Vector2(-BLOCK_SIDE_LENGTH, 0)
		head.rotation_degrees = 180
		current_direction = 'LEFT'
	if next_scheduled_move == 'RIGHT' and current_direction != 'LEFT':
		direction = Vector2(BLOCK_SIDE_LENGTH, 0)
		head.rotation_degrees = 0
		current_direction = 'RIGHT'
	var previous_head_position = head.position
	var new_head_position = head.position + direction

	head.position = new_head_position
	
	emit_signal("move_completed")

func move_body(snake_parts, previous_head_position):
	var cells_visited = []
	for n in range(snake_parts.size(), 0, -1):
		var index = n - 1
		if index == 0:
			snake_parts[index].position = previous_head_position 
		else:
			snake_parts[index].position = snake_parts[index-1].position
		cells_visited.append(snake_parts[index].position)
	return cells_visited

func check_collision_with_edges(head):
	if head.global_position.x < 3 or head.global_position.x > 381:
		Events.emit_signal("hit")
	if head.global_position.y < 3 or head.global_position.y > 211:
		Events.emit_signal("hit")

func check_collision_with_body(cells_visited, head):
	for p in cells_visited:
		if head.position == p:
			Events.emit_signal("hit")

func move(direction):
	if direction == "LEFT":
		if current_direction == "DOWN":
			next_scheduled_move = "RIGHT"
		elif current_direction == "UP":
			next_scheduled_move = "LEFT"
		elif current_direction == "LEFT":
			next_scheduled_move = "DOWN"
		elif current_direction == "RIGHT":
			next_scheduled_move = "UP"
	elif direction == "RIGHT":
		if current_direction == "DOWN":
			next_scheduled_move = "LEFT"
		elif current_direction == "UP":
			next_scheduled_move = "RIGHT"
		elif current_direction == "LEFT":
			next_scheduled_move = "UP"
		elif current_direction == "RIGHT":
			next_scheduled_move = "DOWN"

func can_move(direction):
	var new_position = head.global_position
	
	if direction == "LEFT":
		if current_direction == "DOWN":
			new_position += Vector2(BLOCK_SIDE_LENGTH, 0)
		elif current_direction == "UP":
			new_position += Vector2(-BLOCK_SIDE_LENGTH, 0)
		elif current_direction == "LEFT":
			new_position += Vector2(0, BLOCK_SIDE_LENGTH)
		elif current_direction == "RIGHT":
			new_position += Vector2(0, -BLOCK_SIDE_LENGTH)
	elif direction == "RIGHT":
		if current_direction == "DOWN":
			new_position += Vector2(-BLOCK_SIDE_LENGTH, 0)
		elif current_direction == "UP":
			new_position += Vector2(BLOCK_SIDE_LENGTH, 0)
		elif current_direction == "LEFT":
			new_position += Vector2(0, -BLOCK_SIDE_LENGTH)
		elif current_direction == "RIGHT":
			new_position += Vector2(0, BLOCK_SIDE_LENGTH)
	elif direction == "FORWARD":
		if current_direction == "DOWN":
			new_position += Vector2(0, BLOCK_SIDE_LENGTH)
		elif current_direction == "UP":
			new_position += Vector2(0, -BLOCK_SIDE_LENGTH)
		elif current_direction == "LEFT":
			new_position += Vector2(-BLOCK_SIDE_LENGTH, 0)
		elif current_direction == "RIGHT":
			new_position += Vector2(BLOCK_SIDE_LENGTH, 0)
	else:
		return false

	# Check edges
	if new_position.x < 3 or new_position.x > 381:
		return false
	if new_position.y < 3 or new_position.y > 211:
		return false

	# Check body
	# TODO
	
	return true

func fruit_direction():
	var fruits = get_tree().get_nodes_in_group("Fruit")
	
	var fruit_direction = null
	
	for fruit in fruits:
		var pos = fruit.global_position - head.global_position
		
		if abs(pos.x) < 6:
			if pos.y < 0:
				fruit_direction = "UP"
			else:
				fruit_direction = "DOWN"
			break
		if abs(pos.y) < 6:
			if pos.x < 0:
				fruit_direction = "LEFT"
			else:
				fruit_direction = "RIGHT"
			break

	if current_direction == "DOWN":
		if fruit_direction == "DOWN":
			return "FORWARD"
		elif fruit_direction == "LEFT":
			return "RIGHT"
		elif fruit_direction == "RIGHT":
			return "LEFT"
	elif current_direction == "UP":
		if fruit_direction == "UP":
			return "FORWARD"
		elif fruit_direction == "RIGHT":
			return "RIGHT"
		elif fruit_direction == "LEFT":
			return "LEFT"
	elif current_direction == "LEFT":
		if fruit_direction == "LEFT":
			return "FORWARD"
		elif fruit_direction == "UP":
			return "RIGHT"
		elif fruit_direction == "DOWN":
			return "LEFT"
	elif current_direction == "RIGHT":
		if fruit_direction == "RIGHT":
			return "FORWARD"
		elif fruit_direction == "DOWN":
			return "RIGHT"
		elif fruit_direction == "UP":
			return "LEFT"

	return null
