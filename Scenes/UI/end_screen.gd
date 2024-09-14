extends Control

class_name EndScreen
@onready var victory_panel_container: PanelContainer = $MarginContainer/VictoryPanelContainer
@onready var victory: Label = $MarginContainer/VictoryPanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Victory
@onready var victory_2: Label = $MarginContainer/VictoryPanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Victory2

@onready var defeat_panel_container: PanelContainer = $MarginContainer/DefeatPanelContainer
@onready var defeat_1: Label = $MarginContainer/DefeatPanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Defeat1
@onready var defeat_2: Label = $MarginContainer/DefeatPanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Defeat2

signal reload_game

func _ready() -> void:
	get_tree().paused = true
	hide()
	
func game_end_screen(ending:int):
	get_tree().paused = true
	match ending:
		0:
			victory_panel_container.show()
			victory.show()
		1:
			victory_panel_container.show()
			victory_2.show()
		2:
			defeat_panel_container.show()
			defeat_1.show()
		3:
			defeat_panel_container.show()
			defeat_2.show()



func _on_button_3_pressed() -> void:
	get_tree().quit()


func _on_button_4_pressed() -> void:
	reload_game.emit()
