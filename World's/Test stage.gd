extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	press "key" to restart 
	if Input.is_key_pressed(KEY_DELETE):
		get_tree().change_scene_to_file("res://World's/Test stage.tscn")
#	press "key" to go to Title Screen
	if Input.is_key_pressed(KEY_ESCAPE)|| Input.is_joy_button_pressed(0,JOY_BUTTON_START):
		get_tree().change_scene_to_file("res://UI/Title_Screen.tscn")
