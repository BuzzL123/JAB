extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# When the scene is ready, set the focus to the "local_multiplayer" button.
	$Menu/CenterRow/Buttons/local_multiplayer.grab_focus()

func _on_local_multiplayer_pressed():
	# When the "local_multiplayer" button is pressed, change the scene to "World's/Test stage.tscn".
	get_tree().change_scene_to_file("res://World's/Test stage.tscn")

func _on_options_pressed():
	# When the "options" button is pressed, show the "PopupPanel" and set focus to the "Reset" button.
	$Menu/CenterRow/CenterContainer/PopupPanel.show()
	$Menu/CenterRow/CenterContainer/PopupPanel/ScrollContainer/VBoxContainer/Reset.grab_focus()
	# If the "ui_cancel" input action is pressed, hide the "PopupPanel".
	if Input.is_action_just_pressed("ui_cancel"):
		$Menu/CenterRow/CenterContainer/PopupPanel.hide()

func _on_quit_pressed():
	# When the "quit" button is pressed, quit the game.
	get_tree().quit()
