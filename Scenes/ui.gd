extends Control
@onready var pause_menu: Control = $pause_menu
@onready var grid_container: GridContainer = $"HBoxContainer/Left Menu/PanelContainer/GridContainer"

signal ui_make_building(building)

func _ready() -> void:
	pause_menu.visible = false
	
	#print(building.can_instantiate())
	#var new_building =  building.instantiate()
	#add_child(new_building)

func _on_button_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_menu.visible = false
	else:
		get_tree().paused = true
		pause_menu.visible = true


func _on_building_button_button_make_building(building: Variant) -> void:
	ui_make_building.emit(building)
