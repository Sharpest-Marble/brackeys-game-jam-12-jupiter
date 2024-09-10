extends Node
@onready var buildings_container: Node2D = $BuildingsContainer


func _on_control_ui_make_building(building: Variant) -> void:
	var new_building = building.instantiate()
	buildings_container.add_child(new_building)
