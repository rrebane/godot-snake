extends CanvasLayer

func _ready():
	Events.connect("hit_body", self, "on_hit_body")
	pass # Replace with function body.

func on_hit_body():
	$AnimationPlayer.play("show")
