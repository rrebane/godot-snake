extends CanvasLayer

var fruits_eaten = 0

func _ready():
	Events.connect("hit", self, "on_hit")
	Events.connect("eat_fruit", self, "on_eat_fruit")
	pass # Replace with function body.

func on_hit():
	$AnimationPlayer.play("show")

func on_eat_fruit():
	fruits_eaten += 1
	$ScoreContainer/HBoxContainer/Label.text = str(fruits_eaten)
