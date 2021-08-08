extends Sprite

func check_for_fruit(pos):
	var old_position
	if pos:
		old_position = $Area2D.position
		$Area2D.position = pos
	var areas = $Area2D.get_overlapping_areas()
	var found_fruit = false
	for area in areas:
		if area.is_in_group("Fruit"):
			$AnimationPlayer.play("bite")
			$AudioStreamPlayer.play()
			found_fruit = true
			area.queue_free()
			Events.emit_signal("eat_fruit")
	if pos:
		$Area2D.position = old_position

	return found_fruit

