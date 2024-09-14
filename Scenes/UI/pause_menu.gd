extends Control

class_name PauseMenu

signal display_reference_sheets()
signal restart_game

func _on_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.



func _on_reference_sheets_pressed() -> void:
	hide()
	display_reference_sheets.emit()


func _on_restart_pressed() -> void:
	restart_game.emit()
