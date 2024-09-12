extends CharacterBody2D

class_name JellyPerson

@onready var modifier: Sprite2D = $JellyPersonBody/modifier
@onready var animation_player: AnimationPlayer = $JellyPersonBody/AnimationPlayer
@onready var modifier_animations: AnimationPlayer = $JellyPersonBody/modifier/ModifierAnimations
@onready var state_chart: StateChart = $StateChart
@onready var jelly_outline: Sprite2D = %JellyOutline
@onready var jelly_outline_selected: Sprite2D = $JellyPersonBody/JellyOutlineSelected
@onready var training_timer: Timer = $TrainingTimer

@export var target_location: Vector2 = Vector2(0,0)
@export var selected: bool = false
@export var speed: float = 1000

var layer_active = 1

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


func _ready() -> void:
	update_layers_active(layer_active)
	pass
	

func _physics_process(delta: float) -> void:
	if not  state_chart.find_child("idle")._state_active:
		return
	if global_position.distance_to(target_location) > 15:
		#print(global_position.distance_to(target_location))
		velocity = (target_location-global_position).normalized()*speed
		if global_position.x - target_location.x > 0:
			#print("move left")
			state_chart.send_event("move_left")
		else:
			state_chart.send_event("move_right")
		#print(target_location)
		#print(velocity)
		move_and_slide()
	if global_position.distance_to(target_location)<15 && global_position.distance_to(target_location) > 1:
		#print("nearby")
		velocity = (target_location-global_position).normalized()*speed*.1
		state_chart.send_event("idle")
		#print(target_location)
		#print(velocity)
		move_and_slide()
	if global_position.distance_to(target_location) < 1:
		state_chart.send_event("idle")
	
	
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if state_chart.find_child("Selected")._state_active && event.button_index == MOUSE_BUTTON_RIGHT && event.pressed == false:
			#print("Mouse Click/Unclick at: ", event.position)
			
			target_location.x = clamp(event.position.x,0,1920)
			target_location.y = clamp(event.position.y,0,1080)
		
			#print(event.button_index)
			#print(event.pressed)
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed == false:
			if jelly_outline.visible:
				state_chart.send_event("clicked_on")
				jelly_outline_selected.visible=true
			if not jelly_outline.visible && not event.shift_pressed:
				state_chart.send_event("clicked_off")
				jelly_outline_selected.visible=false
			
		#if event.button_index == MOUSE_BUTTON_MIDDLE && event.pressed == false && selected:
			#state_chart.send_event(class_animation_array[character_class])
			#
		#if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && selected:
			#character_class -= 1
			#character_class %= len(class_animation_array)
			#state_chart.send_event(class_animation_array[character_class])
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP && selected:
			#character_class += 1
			#character_class %= len(class_animation_array)
			#state_chart.send_event(class_animation_array[character_class])
	



func _on_mouse_entered() -> void:
	jelly_outline.visible = true
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	jelly_outline.visible = false
	pass # Replace with function body.

func _on_science_training_state_entered() -> void:
	if character_class != SCIENTIST:
		character_class = SCIENTIST
		state_chart.send_event("start_training")
		training_timer.start()
		await training_timer.timeout
	state_chart.send_event("training_finished")
	state_chart.send_event(class_animation_array[character_class])

func _on_farmer_training_state_entered() -> void:
	if character_class != FARMER:
		character_class = FARMER
		state_chart.send_event("start_training")
		training_timer.start()
		await training_timer.timeout
	state_chart.send_event("training_finished")
	state_chart.send_event(class_animation_array[character_class])

func _on_engineer_training_state_entered() -> void:
	if character_class != ENGINEER:
		character_class = ENGINEER
		state_chart.send_event("start_training")
		training_timer.start()
		await training_timer.timeout
	state_chart.send_event("training_finished")
	state_chart.send_event(class_animation_array[character_class])
	
func _on_comm_training_state_entered() -> void:
	if character_class != COMMUNICATOR:
		character_class = COMMUNICATOR
		state_chart.send_event("start_training")
		training_timer.start()
		await training_timer.timeout
	state_chart.send_event("training_finished")
	state_chart.send_event(class_animation_array[character_class])
	

func update_layers_active(current_layer: int) -> void:
	layer_active = current_layer
	for i in range(1,32):
		set_collision_mask_value(i,false)
		set_collision_layer_value(i,false)
	set_collision_layer_value(layer_active,true)
	set_collision_mask_value(layer_active,true)
