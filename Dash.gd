extends Node2D
const dash_delay = 0.4

var can_dash = true
@onready var timer = $Dash_Timer

# start_dash function: starts the dash timer for a given duration
func start_dash(dur):
	timer.wait_time = dur
	timer.start()

# is_dashing function: returns true if the player is currently dashing
func is_dashing():
	return !timer.is_stopped()

# end_dash function: ends the player's dash, and waits for a delay before the player can dash again
func end_dash():
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true

# _on_dash_timer_timeout function: called when the dash timer finishes, and ends the player's dash
func _on_dash_timer_timeout():
	end_dash()
