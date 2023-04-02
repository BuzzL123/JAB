extends ColorRect


signal fade_finished

func fade_in():
	$AnimationPlayer.play("Fade_In")


func _on_animation_player_animation_finished(anim_name):
	emit_signal("fade_finished")
