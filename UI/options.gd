extends PopupPanel

# FIXME: scrolling with keybord

const PATH := "user://options.ini"
const MAX_VSYNC := 4
const KEYBINDS := [
	"left_1",
	"right_1",
	"jump_1",
	"crouch_1",
	"JAB!_1",
	"dash_1",
	"left_2",
	"right_2",
	"jump_2",
	"crouch_2",
	"JAB!_2",
	"dash_2"
]

@export var Keybind: PackedScene

var config_file: ConfigFile
var current_event: InputEvent
var current_keybind: VBoxContainer
var default_keybinds := {}

# Called when the scene is ready. Hides the current node and the $Press node.
# Initializes the default keybinds for each action and loads the configuration file.
# Updates the options values based on the loaded configuration file.
# For each keybind, instantiates a new Keybind node and connects its signals to the respective functions.
func _ready() -> void:
	hide()
	$Press.hide()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(0))
	await get_tree().create_timer(0.1).timeout
	
	# Initialize default keybinds for each action.
	for keybind in KEYBINDS:
		default_keybinds[keybind] = InputMap.action_get_events(keybind)
	
	# Load the configuration file.
	config_file = ConfigFile.new()
	if config_file.load(PATH) == OK:
		# Set fullscreen option based on configuration file.
		var fullscreen_value = config_file.get_value("visual", "fullscreen", false)
		if fullscreen_value is bool:
			if fullscreen_value:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			%Fullscreen.button_pressed = fullscreen_value
		
		# Set vsync option based on configuration file.
		var vsync_value = config_file.get_value("visual", "vsync", 1)
		if vsync_value is int and vsync_value in range(MAX_VSYNC):
			DisplayServer.window_set_vsync_mode(vsync_value)
			%Vsync.selected = vsync_value
			
		# Set master volume option based on configuration file.
		var master_value = config_file.get_value("audio", "master", 1.0)
		if master_value is float and master_value >= 0.0 and master_value <= 1.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_value))
			%Master.value = master_value
		
		# Set music volume option based on configuration file.
		var music_value = config_file.get_value("audio", "music", 1.0)
		if music_value is float and music_value >= 0.0 and music_value <= 1.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_value))
			%Music.value = music_value
			
		# Set sound volume option based on configuration file.
		var sound_value = config_file.get_value("audio", "sound", 1.0)
		if sound_value is float and sound_value >= 0.0 and sound_value <= 1.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(sound_value))
			%Sound.value = sound_value
			
		# Set keybinds based on configuration file.
		var keybinds = config_file.get_value("keybinds", "keybinds", {})
		if keybinds is Dictionary and keybinds.has_all(KEYBINDS):
			for keybind in KEYBINDS:
				InputMap.action_erase_events(keybind)
				for event in keybinds[keybind]:
					InputMap.action_add_event(keybind, event)
	
	# This function instantiates a keybind UI element for each keybind in KEYBINDS,
	# initializes it with the keybind, adds it to the VBoxContainer, and connects 
	# its event_requested and event_deleted signals to their respective functions.
	for keybind in KEYBINDS:
		var k := Keybind.instantiate()
		k.init(keybind)
		$ScrollContainer/VBoxContainer.add_child(k)
		k.event_requested.connect(on_action_event_requested)
		k.event_deleted.connect(write_keybinds)

# This function pauses the game and centers the options menu popup on the screen.
func show_options() -> void:
	get_tree().paused = true
	popup_centered()

# This function unpauses the game when the options menu popup is hidden.
func _on_popup_hide() -> void:
	get_tree().paused = false

# This function sets the fullscreen setting in the config file and updates the 
# game window's display mode accordingly.
func _on_fullscreen_toggled(button_pressed: bool) -> void:
	config_file.set_value("visual", "fullscreen", button_pressed)
	config_file.save(PATH)
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

# This function sets the vsync setting in the config file and updates the 
# game window's vsync mode accordingly.
func _on_vsync_item_selected(index: int) -> void:
	config_file.set_value("visual", "vsync", index)
	config_file.save(PATH)
	DisplayServer.window_set_vsync_mode(index)

# This function updates the "master" audio volume level in the game's config file and updates the audio bus volume accordingly
func _on_master_value_changed(value):
	config_file.set_value("audio", "master", value)
	config_file.save(PATH)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


# This function updates the "music" audio volume level in the game's config file and updates the audio bus volume accordingly
func _on_music_value_changed(value: float) -> void:
	config_file.set_value("audio", "music", value)
	config_file.save(PATH)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

# This function updates the "sound" audio volume level in the game's config file and updates the audio bus volume accordingly
func _on_sound_value_changed(value: float) -> void:
	config_file.set_value("audio", "sound", value)
	config_file.save(PATH)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(value))

# This function resets various game settings to their default values
func _on_reset_pressed() -> void:
	# Reset fullscreen setting and window mode
	config_file.set_value("visual", "fullscreen", false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	%Fullscreen.button_pressed = false
	
	# Reset VSync setting and update window VSync mode
	config_file.set_value("visual", "vsync", 1)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	%Vsync.selected = 1
	
	# Reset audio master, music, and sound levels
	config_file.set_value("audio", "master", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(1.0))
	%Master.value = 1.0
	
	config_file.set_value("audio", "music", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(1.0))
	%Music.value = 1.0
	
	config_file.set_value("audio", "sound", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(1.0))
	%Sound.value = 1.0
	
	# Reset keybindings to default and update the UI accordingly
	config_file.set_value("keybinds", "keybinds", default_keybinds)
	for keybind in KEYBINDS:
		InputMap.action_erase_events(keybind)
		for event in default_keybinds[keybind]:
			InputMap.action_add_event(keybind, event)
	for keybind_node in get_tree().get_nodes_in_group("keybinds"):
		keybind_node.queue_free()
	for keybind in KEYBINDS:
		var k := Keybind.instantiate()
		k.init(keybind)
		$ScrollContainer/VBoxContainer.add_child(k)
		k.event_requested.connect(on_action_event_requested)
		k.event_deleted.connect(write_keybinds)
	
	# Save the updated config file
	config_file.save(PATH)


# This function handles a request for a new input event from a keybind object.
# It opens a pop-up dialog box that prompts the user to press a key.
# The current keybind object is saved for later use.
func on_action_event_requested(k: VBoxContainer) -> void:
	current_event = null
	$Press.dialog_text = "[Press any button!]"
	$Press.popup_centered()
	current_keybind = k


# This function handles a confirmed input event and saves it to the current keybind object.
# It then calls the write_keybinds function to save the changes to the configuration file.
func _on_press_confirmed() -> void:
	$Press.hide()
	if current_event == null:
		return
	current_keybind.add_event(current_event)
	write_keybinds()


# This function saves all keybinds to the configuration file.
# It first retrieves the current keybinds from the InputMap and stores them in a dictionary.
# The dictionary is then saved to the configuration file.
func write_keybinds() -> void:
	var dict := {}
	for keybind in KEYBINDS:
		dict[keybind] = InputMap.action_get_events(keybind)
	config_file.set_value("keybinds", "keybinds", dict)
	config_file.save(PATH)


# This function handles the selection of an input event from the pop-up dialog box.
# It saves the selected input event for later use.
func _on_press_event_selected(event) -> void:
	$Press.dialog_text = event.as_text()
	current_event = event
