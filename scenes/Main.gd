extends Node2D


## SCENES ##
var fruit = preload("res://scenes/Fruit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("eat_fruit", self, "on_eat_fruit")
	Events.connect("hit_body", self, "on_hit_body")
	pass # Replace with function body.

func on_hit_body():
	$ClassicSnake.queue_free()
	pass # Replace with function body.

func on_eat_fruit():
	spawn_new_fruit()

func spawn_new_fruit():
	var instance = fruit.instance()
	var CELL_LENGTH = 6
	var mx = 120 / CELL_LENGTH
	var y = ceil(rand_range(0, mx)) * CELL_LENGTH
	var x = ceil(rand_range(0, mx)) * CELL_LENGTH
	var p = Vector2(x, y)
	instance.position = p
	add_child(instance)


func _on_Button_pressed():
	LevelManager.goto_scene("res://scenes/Main.tscn")
	pass # Replace with function body.
