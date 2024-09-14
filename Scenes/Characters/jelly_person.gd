extends CharacterBody2D

class_name JellyPerson

@onready var jelly_person_body: Sprite2D = $JellyPersonBody
@onready var modifier: Sprite2D = $JellyPersonBody/modifier
@onready var animation_player: AnimationPlayer = $JellyPersonBody/AnimationPlayer
@onready var modifier_animations: AnimationPlayer = $JellyPersonBody/modifier/ModifierAnimations
@onready var state_chart: StateChart = $StateChart
@onready var jelly_outline: Sprite2D = %JellyOutline
@onready var jelly_outline_selected: Sprite2D = $JellyPersonBody/JellyOutlineSelected
@onready var training_timer: Timer = $TrainingTimer
@onready var area_2d: JellyPersonArea = $Area2D
@onready var selected_state = state_chart.find_child("Selected")
@onready var immovable_states = [
	state_chart.find_child("science_training"),
	state_chart.find_child("farmer_training"),
	state_chart.find_child("engineer_training"),
	state_chart.find_child("comm_training"),
	]

@export var target_location = Vector2.ZERO
@export var selected: bool = false
@export var speed: float = 1000
@export var food_eaten: float = 0.05
@onready var food_timer: Timer = $FoodTimer

var layer_active = 1
var avoid_weight = 0.1
var target_radius = 10

enum {
	ENGINEER,
	COMMUNICATOR,
	FARMER,
	NONE,
	SCIENTIST
}
@export_enum("ENGINEER", "COMMUNICATOR", "FARMER", "NONE","SCIENTIST") var character_class: int
const class_animation_array = [
	"become_engineer",
	"become_communicator",
	"become_farmer",
	"become_blank",
	"become_scientist"
]


signal eat_food(food_eaten:float)

func _ready() -> void:
	state_chart.set_expression_property("character_class",NONE)
	update_layers_active(Globals.current_layer)
	set_global_position(Vector2(1800,900))
	

func _physics_process(delta: float) -> void:
	for state in immovable_states:
		if  state._state_active:
			return
	velocity = Vector2.ZERO
	if target_location:
		#if target_location.x >= global_position.x:
			#state_chart.send_event("move_right")
		#else:
			#state_chart.send_event("move_left")
		# Move toward the target
		# Stop moving when reaching the target
		velocity = global_position.direction_to(target_location)
		if global_position.distance_to(target_location) < target_radius:
			state_chart.send_event("idle")
			target_location = null
	# Add an avoidance vector to move away from other units
	var sd = social_distancing()
	velocity = (velocity + sd * avoid_weight).normalized() * speed
	move_and_slide()
	
func become_selected():
	state_chart.send_event("clicked_on")
func become_unselected():
	state_chart.send_event("clicked_off")
	
	



func _on_mouse_entered() -> void:
	jelly_outline.visible = true
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	jelly_outline.visible = false
	pass # Replace with function body.

func train_for_class(class_type: int):
	if character_class != class_type:
		state_chart.send_event("start_training")
		training_timer.start()
		await training_timer.timeout
		character_class = class_type
		state_chart.set_expression_property("character_class",character_class)
		state_chart.send_event(class_animation_array[character_class])
	state_chart.send_event.call_deferred("start_working")

func _on_science_training_state_entered() -> void:
	train_for_class(SCIENTIST)
func _on_farmer_training_state_entered() -> void:
	train_for_class(FARMER)
func _on_engineer_training_state_entered() -> void:
	train_for_class(ENGINEER)
func _on_comm_training_state_entered() -> void:
	train_for_class(COMMUNICATOR)
	

func update_layers_active(current_layer: int) -> void:
	layer_active = current_layer
	for i in range(1,32):
		set_collision_mask_value(i,false)
		set_collision_layer_value(i,false)
	set_collision_layer_value(layer_active,true)
	set_collision_mask_value(layer_active,true)
	area_2d.update_layers_active(layer_active)

func social_distancing():
	var neighbors = area_2d.get_overlapping_areas()
	var result: Vector2 = Vector2.ZERO
	if neighbors:
		for overlap in neighbors:
			if overlap is JellyPersonArea:
				result += overlap.global_position.direction_to(global_position)
		result /= len(neighbors)
	return result.normalized()
				


func _on_debugging_timer_timeout() -> void:
	#print("target location:")
	#print(target_location)
	#print("global position:")
	#print(global_position)
	pass


func _on_working_state_entered() -> void:
	set_physics_process(false)
	pass # Replace with function body.


func _on_working_state_exited() -> void:
	set_physics_process(true)
	pass # Replace with function body.


func _on_food_timer_timeout() -> void:
	eat_food.emit(food_eaten)
	pass # Replace with function body.


func _on_selected_state_entered() -> void:
	jelly_outline_selected.visible = true
	pass # Replace with function body.


func _on_not_selected_state_entered() -> void:
	jelly_outline_selected.visible = false
	pass # Replace with function body.
