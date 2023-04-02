extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Menu/CenterRow/Buttons/local_multiplayer.grab_focus()

func _on_local_multiplayer_pressed():
	get_tree().change_scene_to_file("res://World's/Test stage.tscn")


func _on_options_pressed():
	$Menu/CenterRow/CenterContainer/PopupPanel.show()
	$Menu/CenterRow/CenterContainer/PopupPanel/ScrollContainer/VBoxContainer/Reset.grab_focus()
	if Input.is_action_just_pressed("ui_cancel"):
		$Menu/CenterRow/CenterContainer/PopupPanel.hide()

func _on_quit_pressed():
	get_tree().quit()

