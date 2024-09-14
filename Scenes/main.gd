extends Node2D

var cheat_mode = true

@onready var box_select: Node2D = $BoxSelect
@onready var control: Control = $CanvasLayer/Control
@onready var buildings_container: Node2D = $BuildingsContainer
@onready var time_till_next_day: Timer = $TimeTillNextDay
@onready var screens_array: Array[Sprite2D] = [
	$FlyingFernsBg,
	$HighestLevelSouthernWallBg,
	$MeetingRoom,
	$HighestLevelBgUpwellingGatherer,
	$JourneyDownBg,
	$MetalDiversBg,
]
var current_screen: int = 0
@onready var end_screen: EndScreen = $CanvasLayer/EndScreen

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
@onready var negotiate_passage_progress_bar:ProgressBar = control.find_child("NegotiatePassageBar")
@onready var negotiation_rate_label: Label = control.find_child("NegotiationRateLabel")
@onready var passive_resource_timer: Timer = $PassiveResourceTimer
@onready var worker_transport_shuttle: WorkerTransportShuttle = $WorkerTransportShuttle
@onready var jelly_person_spawn_clock: Timer = $JellyPersonSpawnClock
var negotiation_building

const JELLY_PERSON = preload("res://Scenes/Characters/jelly_person.tscn")
const NUM_ARK_POINTS: int = 6
# victory condition variables
var ark_progress: float = 0
var ship_progress: float = 0
var total_negotiation_strength: float = 0
var victory_condition_met: int = victory_conditions.FAIL
var days_till_storm: int = 7
# drag selection varaibles
var dragging = false  # Are we currently dragging?
var selected = []  # Array of selected units.
var drag_start = Vector2.ZERO  # Location where drag began.
var select_rect = RectangleShape2D.new()  # Collision shape for drag box.


enum screens {
	FLYING_FERNS,
	SOUTHERN_WALL,
	MEETING_ROOM,
	UPWELLING,
	JOURNEY_DOWN,
	METAL_DIVERS
}

enum victory_conditions {
	SHIP_CONDITION,
	ARK_CONDITION,
	FAIL,
	STARVED,
}

enum resources {
	SCIENCE,
	METAL,
	FOOD,
	COMM
}

enum building_types {
	Mine, 
	Comms, 
	Farm,
	Science, 
	Upgrade,
	ShipEnd,
	Ship,
	ShipEngine,
	Ark,
	None	
}

var resources_array: Array[float] = [
	10,
	10,
	50,
	20
]

var passive_resource_gen: Array[float] = [
	0.1,
	0.1,
	0.1,
	0.1
]

var resource_deltas: Array[float] = [
	0.1,
	0.1,
	0.1,
	0.1
]



func _ready() -> void:
	update_readouts()
	spawn_jelly_person(Vector2(1500,900))
	print(current_screen)
	for level in len(screens_array):
		for child in screens_array[level].get_children():
			if child is JellyPerson:
				child.update_layers_active(Globals.current_layer+level)
				#child.area_2d.area_shape_entered.connect(test_area_shape_entered)
						#print(childchild)
			if child is BuildingPoint:
				child.building_resource_produced.connect(add_resources)
				child.building_built.connect(pay_for_building)
				child.update_layers_active(Globals.current_layer + level)
				child.update_resource_delta.connect(update_resouce_deltas)
				#child.set_collision_mask_value(Globals.current_layer + level,true)
				#child.set_collision_layer_value(Globals.current_layer + level,true)
				if level == screens.UPWELLING:
					child.building_built.connect(update_ark_victory_progress)
				if level == screens.SOUTHERN_WALL &&\
					child.building_type in [
						building_types.ShipEnd,
						building_types.Ship,
						building_types.ShipEngine
						]:
					child.building_built.connect(update_ship_victory_progress)
			if child is Building && level == screens.MEETING_ROOM:
				child.layer_active = Globals.current_layer + level
				child.negotiate.connect(negotiate_passage)
				child.update_resouce_delta.connect(update_resouce_deltas)
				child.global_position = Vector2(960,540)
				child.place_building()
				negotiation_building = child

func _process(delta: float) -> void:
	update_readouts()
	update_progress()
		#print(buildings_container.get_child(0).layer_active)
	if resources_array[resources.FOOD] <0:
		victory_condition_met = victory_conditions.STARVED
		game_end()
	if days_till_storm <= 0:
		game_end()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MASK_RIGHT && buildings_container.get_children():
			buildings_container.get_child(0).queue_free()
		# move all selected jellypeople
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed == false:
			for selected_jelly in selected:
				if selected_jelly is JellyPerson:
					var target: Vector2 = Vector2.ZERO
					selected_jelly.target_location = target
					selected_jelly.target_location.x = clamp(event.position.x,0,1920)
					selected_jelly.target_location.y = clamp(event.position.y,0,1080)
					if selected_jelly.target_location.x - selected_jelly.global_position.x > 0:
						selected_jelly.state_chart.send_event("move_right")
					else:
						selected_jelly.state_chart.send_event("move_left")
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			#if selected.size() == 0:
			# clear previous selection
			if selected.size() != 0:
				for select in selected:
					if select:
						select.become_unselected()
			selected = []
			
			# If the mouse was clicked, start dragging
			box_select.dragging = true
			box_select.drag_start = event.position
			box_select.drag_end = event.position
			
			# get onclick selection
			var space = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.collision_mask = 1 << (Globals.current_layer - 1)
			query.collide_with_areas = true
			query.position = get_global_mouse_position()
			for potential_selected in space.intersect_point(query):
				#print(potential_selected)
				if potential_selected.collider is JellyPersonArea:
					selected.append(potential_selected.collider.get_parent())
					potential_selected.collider.get_parent().become_selected()
		
		# If the mouse is released and is dragging, stop dragging
		elif box_select.dragging:
			box_select.dragging = false
			box_select.queue_redraw()
			box_select.drag_end = event.position
			select_rect.extents = abs(box_select.drag_end - box_select.drag_start) / 2
			
			var space = get_world_2d().direct_space_state
			var query = PhysicsShapeQueryParameters2D.new()
			query.shape = select_rect
			query.collision_mask = 1 << (Globals.current_layer - 1)
			query.collide_with_areas = true
			query.transform = Transform2D(0, (box_select.drag_end + box_select.drag_start) / 2)
			for potential_selected in space.intersect_shape(query):
				if potential_selected.collider is JellyPerson:
					selected.append(potential_selected.collider)
					potential_selected.collider.become_selected()
	if event is InputEventMouseMotion and box_select.dragging:
		box_select.drag_end = event.position
		box_select.queue_redraw()

func update_ark_victory_progress(resource_cost,building_type):
	if building_type == building_types.Ark:
		ark_progress += 100.0/NUM_ARK_POINTS
	update_progress()

func update_ship_victory_progress(resource_cost,building_type):
	print("ship part built!")
	if building_type == building_types.Ship:
		ship_progress += 10
	if building_type == building_types.ShipEnd:
		ship_progress += 25
	if building_type == building_types.ShipEngine:
		ship_progress += 15
	update_progress()

func negotiate_passage(negotiation_strength, comm_cost):
	total_negotiation_strength += negotiation_strength
	total_negotiation_strength = min(30,total_negotiation_strength)
	if total_negotiation_strength < 29.9:
		negotiation_rate_label.text = "+ %0.02f/s" % negotiation_strength
		resources_array[resources.COMM] -= comm_cost
	
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
		storm_label = "\n" +str(days_till_storm) + " Days"
	else:
		if not $FinalDayMusic.playing:
			$MusicPlayer.playing = false
			$FinalDayMusic.play()
		storm_label = "\nThe Final Day"
	time_readout.text = "Next Day: " + str(int(time_till_next_day.time_left)) + " (s)" + storm_label

func pay_for_building(resource_costs:Array[int] = [0,0,0,0],building_type:int = 1):
	$SFXHolder/PlaceBuildingSFX.play()
	if not cheat_mode:
		for i in len(resources_array):
			resources_array[i] -= resource_costs[i]

func add_resources(resource_type:int,resource_qty:int=1):
	resources_array[resource_type] += resource_qty

func _on_control_ui_make_building(building: Variant, resource_cost, resources_produced,resource_timer) -> void:
	if not cheat_mode:
		for i in len(resource_cost):
			if resource_cost[i] > max(resources_array[i],0):
				need_more_resources()
				return
	if buildings_container.get_children():
		buildings_container.get_child(0).queue_free()
	var new_building: Building = building.instantiate()
	new_building.apply_scale(Vector2(0.3,0.3))
	new_building.layer_active = Globals.current_layer
	new_building.resource_cost = resource_cost
	new_building.resource_qty = resources_produced
	new_building.building_process_time = resource_timer
	new_building.deselect_worker.connect(deselect_worker)
	#print(Globals.current_layer)
	#print(new_building.layer_active)
	#for child in new_building.get_children():
		#if child is CollisionObject2D:
			#child.set_collision_mask_value(Globals.current_layer,true)
			#child.set_collision_layer_value(Globals.current_layer,true)
	buildings_container.add_child(new_building)

func deselect_worker(worker):
	for i in selected.size():
		if selected[i] == worker:
			worker.state_chart.send_event("clicked_off")
		selected[i] = null
			

# TODO: add transition effect here
func _on_control_go_to_screen(screen: Variant) -> void:
	$SFXHolder/TravelSFX.play()
	for screen_thing in screens_array:
		screen_thing.visible = false
	screens_array[screen].visible = true
	Globals.current_layer = 17 + screen
	if buildings_container.get_children():
		var temp_building: Building = buildings_container.get_child(0)
		temp_building.update_layers_active(Globals.current_layer)
	current_screen = screen


func _on_time_till_next_day_timeout() -> void:
	days_till_storm -= 1
	if days_till_storm < 0:
		game_end()
	pass # Replace with function body.

func game_end():
	get_tree().paused = true
	end_screen.show()
	end_screen.game_end_screen(victory_condition_met)

func update_progress():
	ark_progress_bar.set_value(ark_progress)
	ship_progress_bar.set_value(ship_progress)
	negotiate_passage_progress_bar.set_value(total_negotiation_strength)
	if ark_progress >= 90:
		victory_condition_met = 1
	if ship_progress >= 69 && total_negotiation_strength >= 29:
		victory_condition_met = 0
		
func _on_control_go_next_day() -> void:
	# give the player the resources they would have gained for waiting
	for i in len(resources_array):
		resources_array[i] += resource_deltas[i] * time_till_next_day.time_left
	var num_negotiators = negotiation_building.current_workers
	var negotiator_eff = negotiation_building.worker_efficiency
	total_negotiation_strength += \
		num_negotiators * \
		negotiator_eff * \
		time_till_next_day.time_left 
	time_till_next_day.start()
	days_till_storm -= 1
	

func _on_passive_resource_timer_timeout() -> void:
	for i in len(resources_array):
		resources_array[i] += passive_resource_gen[i]


func _on_dispense_workers_pressed() -> void:
	var number_to_spawn = worker_transport_shuttle.workers_in_shuttle
	if number_to_spawn == 0:
		return
	for i in range(number_to_spawn):
		spawn_jelly_person(Vector2(1800 - i *20,clamp(1000 - i *20,500,1000)))
	worker_transport_shuttle.workers_in_shuttle = 0

func jelly_eat(food_eaten:float):
	resources_array[resources.FOOD] -= food_eaten
	

func spawn_jelly_person(target_loc):
	var new_jelly_person = JELLY_PERSON.instantiate()
	new_jelly_person.target_location = target_loc
	new_jelly_person.eat_food.connect(jelly_eat)
	resource_deltas[resources.FOOD] -= new_jelly_person.food_eaten
	screens_array[current_screen].add_child(new_jelly_person)

func _on_control_hoover_workers_pressed() -> void:
	selected = []
	var jelly_person_eat_rate = 0.05
	worker_transport_shuttle.hoover_workers()
	var update_delta_delta:Array[float] = [0,0,0,0]
	update_delta_delta[resources.FOOD] = worker_transport_shuttle.workers_in_shuttle * jelly_person_eat_rate
	update_resouce_deltas(update_delta_delta)


func need_more_resources():
	var error_panel: PanelContainer = $CanvasLayer/PanelContainer
	error_panel.set_self_modulate(Color(0,0,0,0))
	error_panel.show()
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(error_panel,"self_modulate",Color(1,1,1,1),0.1)
	fade_tween.tween_property(error_panel,"self_modulate",Color(1,1,1,1),1)
	fade_tween.tween_property(error_panel,"self_modulate",Color(0,0,0,0),0.5)
	fade_tween.tween_property(error_panel,"visible",false,0.001)


func _on_control_spawn_new_workers(resource_costs: Array[int]) -> void:
	if not cheat_mode:
		for i in resources_array.size():
			if max(resources_array[i],0) < resource_costs[i]:
				need_more_resources()
				return
		for i in resources_array.size():
			resources_array[i] -= resource_costs[i]
	spawn_jelly_person(Vector2(1750,920))
	


func restart() -> void:
	Globals.current_layer = 17
	get_tree().reload_current_scene()
