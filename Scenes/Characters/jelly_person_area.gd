extends Area2D
class_name JellyPersonArea
func update_layers_active(layer_active: int = Globals.current_layer) -> void:
	for i in range(1,32):
		set_collision_mask_value(i,false)
		set_collision_layer_value(i,false)
	set_collision_layer_value(layer_active,true)
	set_collision_mask_value(layer_active,true)
