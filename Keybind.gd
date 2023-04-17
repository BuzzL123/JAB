extends VBoxContainer

# A signal that is emitted when an event is requested
signal event_requested(this: VBoxContainer)

# A signal that is emitted when an event is deleted
signal event_deleted

# A PackedScene that represents a keybind action
@export var KeybindAction: PackedScene

# The action associated with this instance
var action: String

# Initializes this instance with the specified action
func init(a: String) -> void:
	action = a
	$HBoxContainer/Label.text = action
	for event in InputMap.action_get_events(action):
		var k := KeybindAction.instantiate()
		k.init(event)
		add_child(k)
		k.deleted.connect(on_event_deleted)

# Deletes the specified event from the action and emits event_deleted signal
func on_event_deleted(event: InputEvent) -> void:
	InputMap.action_erase_event(action, event)
	event_deleted.emit()

# Called when the add button is pressed, emits event_requested signal
func _on_add_pressed() -> void:
	event_requested.emit(self)
	
# Adds the specified event to the action and creates a new KeybindAction instance to represent it
func add_event(event: InputEvent) -> void:
	var k := KeybindAction.instantiate()
	k.init(event)
	add_child(k)
	k.deleted.connect(on_event_deleted)
	InputMap.action_add_event(action, event)
