extends Node

@onready var control: Control = $CanvasLayer/Control

@onready var buildings_container: Node2D = $BuildingsContainer
@onready var time_till_next_day: Timer = $TimeTillNextDay
@onready var screens_array: Array[Sprite2D] = [
	$FlyingFernsBg,
	$HighestLevelSouthernWallBg,
	$HighestLevelBgUpwellingGatherer,
	$MeetingRoom,
	$JourneyDownBg,
	$MetalDiversBg,
]

#basically all of these should probably have been done in the ui scene instead of here
# oh well
@onready var time_readout:Label = control.find_child("TimeTillNextDayLabel")
@onready var science_resource_readout:Label = control.find_child("ScienceResourceLabel")
@onready var science_delta:Label = control.find_child("ScienceDelta")
@onready var metal_resource_readout:Label = control.find_child("MetalResourceLabel")
@onready var metal_delta:Label = control.find_child("MetalDelta")
@onready var food_resource_readout:Label = control.find_child("FoodResourceLabel")
@onready var food_delta:Label = control.find_child("FoodDelta")
@onready var comm_resource_readout:Label = control.find_child("CommResourceLabel")
@onready var comm_delta:Label = control.find_child("CommDelta")
@onready var ark_progress_bar: ProgressBar = control.find_child("ArkProgressBar")
@onready var ship_progress_bar: ProgressBar = control.find_child("ShipProgressBar")
@onready var passive_resource_timer: Timer = $PassiveResourceTimer


var ark_progress: float = 0
var ship_progress: float = 0
var victory_condition_met: int = 0
var days_till_storm: int = 7

var current_layer = 17
enum screens {
	UPWELLING,
	MEETING_ROOM,
	SOUTHERN_WALL,
	FLYING_FERNS,
	JOURNEY_DOWN,
	METAL_DIVERS
}

enum resources {
	SCIENCE,
	METAL,
	FOOD,
	COMM
}

var resources_array: Array[float] = [
	10,
	10,
	10,
	10
]

var passive_resource_gen: Array[float] = [
	0.1,
	0.1,
	0.1,
	0.1
]

var resource_deltas: Array[float] = [
	0,
	0,
	0,
	0
]

func _ready() -> void:
	update_readouts()
	for level in len(screens_array):
		for child in screens_array[level].get_children():
			if child is JellyPerson:
				child.update_layers_active(current_layer+level)
				for childchild in child.get_children():
					if childchild is JellyPersonArea:
						childchild.update_layers_active(current_layer + level)
						#print(childchild)
			if child is BuildingPoint:
				child.building_resource_produced.connect(add_resources)
				child.building_built.connect(pay_for_building)
				child.update_layers_active(current_layer + level)
				child.update_resource_delta.connect(update_resouce_deltas)
				#child.set_collision_mask_value(current_layer + level,true)
				#child.set_collision_layer_value(current_layer + level,true)

func _process(delta: float) -> void:
	update_readouts()
		#print(buildings_container.get_child(0).layer_active)
	if days_till_storm <= 0:
		game_end()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MASK_RIGHT && buildings_container.get_children():
			buildings_container.get_child(0).queue_free()

#TODO: Make jellyperson spawner

#TODO: add building for resource dropoff

#TODO: add resource collection

#TODO: add jellyperson transportation method

#TODO: Add beginning and ending cutscenes + tutorial

func update_resouce_deltas(resource_delta_delta:Array[float]):
	#print("updating resource deltas")
	for i in len(resource_deltas):
		resource_deltas[i] += resource_delta_delta[i]

func update_readouts():
	science_delta.text = "%.02f/s" % resource_deltas[resources.SCIENCE]
	metal_delta.text = "%.02f/s" % resource_deltas[resources.METAL]
	food_delta.text = "%.02f/s" % resource_deltas[resources.FOOD]
	comm_delta.text = "%.02f/s" % resource_deltas[resources.COMM]
	
	science_resource_readout.text = "%.02f"%resources_array[resources.SCIENCE]
	metal_resource_readout.text = "%.02f"%resources_array[resources.METAL]
	food_resource_readout.text = "%.02f"%resources_array[resources.FOOD]
	comm_resource_readout.text = "%.02f"%resources_array[resources.COMM]
	
	var storm_label: String
	if days_till_storm > 1:
		storm_label = "\n" +str(days_till_storm) + " Days Before Storm of Centuries"
	else:
		storm_label = "\nThe Final Day"
	time_readout.text = "Next Day: " + str(int(time_till_next_day.time_left)) + " (s)" + storm_label

func pay_for_building(resource_costs:Array[int] = [0,0,0,0]):
	for i in len(resources_array):
		resources_array[i] -= resource_costs[i]

func add_resources(resource_type:int,resource_qty:int=1):
	resources_array[resource_type] += resource_qty

func _on_control_ui_make_building(building: Variant, resource_cost) -> void:
	for i in len(resource_cost):
		if resource_cost[i] > resources_array[i]:
			return
	if buildings_container.get_children():
		buildings_container.get_child(0).queue_free()
	var new_building: Building = building.instantiate()
	new_building.apply_scale(Vector2(0.3,0.3))
	new_building.layer_active = current_layer
	new_building.resource_cost = resource_cost
	#print(current_layer)
	#print(new_building.layer_active)
	#for child in new_building.get_children():
		#if child is CollisionObject2D:
			#child.set_collision_mask_value(current_layer,true)
			#child.set_collision_layer_value(current_layer,true)
	buildings_container.add_child(new_building)

# TODO: add transition effect here
func _on_control_go_to_screen(screen: Variant) -> void:
	for screen_thing in screens_array:
		screen_thing.visible = false
	screens_array[screen].visible = true
	current_layer = 17 + screen
	if buildings_container.get_children():
		var temp_building: Building = buildings_container.get_child(0)
		temp_building.update_layers_active(current_layer)


func _on_time_till_next_day_timeout() -> void:
	days_till_storm -= 1
	if days_till_storm < 0:
		game_end()
	pass # Replace with function body.

func game_end():
	if victory_condition_met > 0:
		print("you win!")
	else:
		print("you lose :( everyone is ded")
	get_tree().quit()

func update_progress():
	ark_progress_bar.set_value(ark_progress)
	ship_progress_bar.set_value(ship_progress)
	if ark_progress >= 100:
		victory_condition_met = 2
	if ship_progress >= 100:
		victory_condition_met = 1

func _on_control_go_next_day() -> void:
	# give the player the resources they would have gained for waiting
	for i in len(resources_array):
		resources_array[i] += resource_deltas[i] * time_till_next_day.time_left
	time_till_next_day.start()
	days_till_storm -= 1
	

func _on_passive_resource_timer_timeout() -> void:
	for i in len(resources_array):
		resources_array[i] += passive_resource_gen[i]
