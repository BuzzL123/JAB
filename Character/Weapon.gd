extends Area2D

const damage = 10


@onready var anim = $"../AnimationPlayer"


func attack():
	anim.play("JAB!")

func _on_body_entered(body) -> void:
	if body.has_method("take_damage"):
		
		var pos = body.get_position()
		var direction = pos - global_position
		if body.is_on_floor():
			if direction[0] > 0:
				print('left')
				body.take_damage(damage, Vector2(300,0))
				print('left')
			elif direction[0] < 0:
				print('right')
				body.take_damage(damage, Vector2(-300,0))
				print('right')
		else:
			body.take_damage(damage)
	await get_tree().create_timer(0.20).timeout
