extends Area2D
class_name JellyPersonArea
var layer_active = 1
func update_layers_active(current_layer: int) -> void:
	layer_active = current_layer

	for i in range(1,32):
		set_collision_mask_value(i,false)
		set_collision_layer_value(i,false)
	set_collision_layer_value(layer_active,true)
	set_collision_mask_value(layer_active,true)
