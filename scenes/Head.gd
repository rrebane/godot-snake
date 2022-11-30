extends Sprite

func check_for_fruit():
	var areas = $Area2D.get_overlapping_areas()
	var found_fruit = false
	for area in areas:
		if area.is_in_group("Fruit"):
			$AnimationPlayer.play("bite")
			$AudioStreamPlayer.play()
			area.queue_free()
			Events.emit_signal("eat_fruit")
			return

