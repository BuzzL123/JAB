extends Node

# Define a class called StateMachine
class_name StateMashine

# Create variables to hold the current and previous states, and a dictionary of all possible states
var state = null : set = set_state # state property, with setter set_state() and getter _get_state()
var previous_state = null
var states = { }

# Get a reference to the parent node (i.e., the node that the script is attached to)
@onready var parent = get_parent()

# The main function that runs during each physics frame, checking for state changes
func _physics_process(delta):
	if state != null:
		_state_logic(delta) # Run the current state's logic
		var transition = _get_transition(delta) # Get the next state to transition to
		if transition != null:
			set_state(transition) # If there is a transition, set the new state

# A placeholder function for running the logic of the current state
func _state_logic(delta):
	pass

# A placeholder function for determining the next state to transition to
func _get_transition(delta):
	return null

# A placeholder function for when a new state is entered
func _enter_state(new_state, old_state):
	pass

# A placeholder function for when a state is exited
func _exit_state(new_state, old_state):
	pass

# Set the new state
func set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state, new_state) # If there was a previous state, run its exit function
	if new_state != null:
		_enter_state(new_state, previous_state) # If there is a new state, run its entry function

# Add a new state to the states dictionary
func add_state(state_name):
	states[state_name] = states.size()
