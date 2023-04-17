extends Control
# not in use

func _ready():
	$CenterContainer/VBoxContainer/TextureButton.grab_focus()

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://UI/Title_Screen.tscn")
