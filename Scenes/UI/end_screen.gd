extends Control

class_name EndScreen

@onready var victory: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Victory
@onready var victory_2: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Victory2
@onready var defeat_1: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Defeat1
@onready var defeat_2: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Defeat2

func _ready() -> void:
	get_tree().paused = true
	hide()
	
func game_end_screen(ending:int):
	get_tree().paused = true
	match ending:
		0:
			victory.show()
		1:
			victory_2.show()
		2:
			defeat_1.show()
		3:
			defeat_2.show()



func _on_button_3_pressed() -> void:
	get_tree().quit()
