extends Node
@onready var buildings_container: Node2D = $BuildingsContainer


func _on_control_ui_make_building(building: Variant) -> void:
	var new_building = building.instantiate()
	new_building.apply_scale(Vector2(0.5,0.5))
	buildings_container.add_child(new_building)


#TODO: make jellypeople selectable from here
