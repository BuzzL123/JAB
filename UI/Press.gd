extends AcceptDialog

# This signal is emitted when an InputEvent is selected
signal event_selected(event: InputEvent)


# This function is called when an unhandled key input is detected
# It emits the event_selected signal with the InputEvent argument
func _unhandled_key_input(event: InputEvent) -> void:
	event_selected.emit(event)


# This function is called when the visibility of the node changes
# It enables or disables the processing of unhandled key inputs based on the visibility status
# If the node is now visible and a GUI element has focus, it releases the focus
func _on_visibility_changed() -> void:
	set_process_unhandled_key_input(visible)
	if visible and gui_get_focus_owner():
		gui_get_focus_owner().release_focus()
