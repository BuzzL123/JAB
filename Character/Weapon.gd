extends Area2D

# This script extends the Area2D class and defines a hitbox for an attack

const damage = 10  # Sets the amount of damage that this attack deals to enemies

@onready var anim = $"../AnimationPlayer"  # Gets a reference to the AnimationPlayer node and assigns it to anim variable
@onready var anim_tree = $"../AnimationTree"  # Gets a reference to the AnimationTree node and assigns it to anim_tree variable

func attack():  # Defines a function to play the attack animation
	anim.play("JAB!")
	

func _on_body_entered(body) -> void:  # Defines a function that is called when another object enters this object's area
	if body.has_method("take_damage"):  # Checks if the body has a "take_damage" function
		var pos = body.get_position()  # Gets the position of the body that entered the hitbox
		var direction = pos - global_position  # Calculates the direction from the hitbox to the body that entered it
		$blood_v.emitting = true
		if body.is_on_floor():  # Checks if the body that entered the hitbox is on the floor
			if direction[0] > 0:  # If the body is to the left of the hitbox, it takes damage and is knocked to the right
				print('left')
				body.take_damage(damage, Vector2(300,0))
				print('left')
			elif direction[0] < 0:  # If the body is to the right of the hitbox, it takes damage and is knocked to the left
				print('right')
				body.take_damage(damage, Vector2(-300,0))
				print('right')
		else:  # If the body that entered the hitbox is not on the floor, it just takes damage
			body.take_damage(damage)
	await get_tree().create_timer(0.20).timeout  # Creates a timer to delay the next attack
