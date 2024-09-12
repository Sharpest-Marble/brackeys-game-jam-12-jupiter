extends Control
@onready var pause_menu: Control = $pause_menu
@onready var grid_container: GridContainer = $"HBoxContainer/Left Menu/PanelContainer/ScrollContainer/GridContainer"

signal ui_make_building(building)
enum screens {
	UPWELLING,
	MEETING_ROOM,
	SOUTHERN_WALL,
	FLYING_FERNS,
	JOURNEY_DOWN,
	METAL_DIVERS
}

signal go_next_day()

signal go_to_screen(screen)

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


func _on_building_button_button_make_building(building: Variant, resource_cost) -> void:
	ui_make_building.emit(building,resource_cost)


func _on_building_button_2_button_make_building(building: Variant, resource_cost) -> void:
	ui_make_building.emit(building,resource_cost)
	pass # Replace with function body.


func _on_building_button_3_button_make_building(building: Variant, resource_cost) -> void:
	ui_make_building.emit(building,resource_cost)


func _on_building_button_4_button_make_building(building: Variant, resource_cost) -> void:
	ui_make_building.emit(building,resource_cost)


func _on_homeland_button_pressed() -> void:
	go_to_screen.emit(screens.UPWELLING)

func _on_meeting_room_button_pressed() -> void:
	go_to_screen.emit(screens.MEETING_ROOM)

func _on_flying_ferns_button_pressed() -> void:
	go_to_screen.emit(screens.FLYING_FERNS)


func _on_southern_wall_button_pressed() -> void:
	go_to_screen.emit(screens.SOUTHERN_WALL)


func _on_journey_down_button_pressed() -> void:
	go_to_screen.emit(screens.JOURNEY_DOWN)


func _on_mines_button_pressed() -> void:
	go_to_screen.emit(screens.METAL_DIVERS)


func _on_next_day_button_pressed() -> void:
	go_next_day.emit()
