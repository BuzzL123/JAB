extends "res://Character/StateMachine.gd"

@onready var id = get_parent().player_id
@onready var anim = $"../AnimationPlayer"

func _ready():
	add_state("IDLE")
	add_state("RUN")
	add_state("JUMP")
	add_state("FALL")
	add_state("DASH")
	add_state("JAB")
	add_state("DEAD")
	add_state("CROUCH")

	call_deferred("set_state", states.IDLE)

func _state_logic(delta):
#	parent._physics_process(delta)
#	parent._apply_gravity(delta)
#	parent._apply_movement()
	pass
func _get_transition(delta):
	parent.move_and_slide()

	match state:
		states.IDLE:
			pass

		states.RUN:
			pass

		states.JUMP:
			pass

		states.FALL:
			pass

		states.DASH:
			pass

		states.CROUCH:
			pass

		states.JAB:
			pass

		states.DEAD:
			parent.die()
			

func _enter_state(new_state, old_state):
	match state:
		
		states.RUN:
			anim.play("run")

		states.JUMP:
			anim.play("jump")

		states.FALL:
			anim.play("fall")

		states.DASH:
			anim.play("dash")

		states.CROUCH:
			anim.play("crouch")

		states.JAB:
			anim.play("JAB!")

		states.DEAD:
			anim.play("Dead")

func _exit_state(new_state, old_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

