extends Control


func _on_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
