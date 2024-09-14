extends Area2D
class_name BuildingPoint
@export_enum("Mine", "Comms", "Farm","Science", "Upgrade","ShipEnd","Ship","ShipEngine","Ark","None") var building_type: int
@export var layer_active: int = 17
var building: Building = null

signal building_resource_produced(resource_type:int)
signal building_built(resource_costs:Array[int], building_type:int)
signal update_resource_delta(resource_delta_delta: Array[float])

func update_layers_active(current_layer: int) -> void:
	layer_active = current_layer
	for i in range(1,32):
		set_collision_mask_value(i,false)
		set_collision_layer_value(i,false)
	set_collision_layer_value(layer_active,true)
	set_collision_mask_value(layer_active,true)
	
#func _on_area_entered(area: Area2D) -> void:
	#if area.get_parent() is Building:
		#building = area.get_parent()
		#if area.name == "SnapTo" && building.building_type == building_type:
			#building.placeable = true
			#building.set_self_modulate(Color(0.1,1,0.1,0.5))
			#building.global_position = global_position
func _on_mouse_entered() -> void:
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area.get_parent() is Building:
			building = area.get_parent()
			if area.name == "SnapTo" && building.building_type == building_type:
				building.placeable = true
				building.set_self_modulate(Color(0.1,1,0.1,0.5))
				building.global_position = global_position


func _on_mouse_exited() -> void:
	if building and building != null:
		building.placeable = false
		building.set_self_modulate(Color(0.1,0.1,1,0.5))
		building = null
	pass # Replace with function body.


func _on_building_resource_produced(resource_type: int, resource_qty: int = 1):
	building_resource_produced.emit(resource_type, resource_qty)

func update_resource_delta_fn(resource_delta_delta:Array[float]):
	update_resource_delta.emit(resource_delta_delta)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && building && building.building_type == building_type:
			building.reparent($".")
			building.produced_resource.connect(_on_building_resource_produced)
			building.update_resouce_delta.connect(update_resource_delta_fn)
			building_built.emit(building.resource_cost, building_type)
			building.place_building()
			$"CollisionShape2D".disabled = true
			# if the building being built is for the ship or ark, it's not upgradable
			if building_type in range(6,9):
				building_type == 10
			building_type = 5
			#find_child("CollisionShape2D").set_disabled(true)
			
