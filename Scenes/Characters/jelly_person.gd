extends CharacterBody2D

@onready var modifier: Sprite2D = $JellyPersonBody/modifier
@onready var animation_player: AnimationPlayer = $JellyPersonBody/AnimationPlayer
@onready var modifier_animations: AnimationPlayer = $JellyPersonBody/modifier/ModifierAnimations
@onready var state_chart: StateChart = $StateChart
@onready var jelly_outline: Sprite2D = %JellyOutline
@onready var jelly_outline_selected: Sprite2D = $JellyPersonBody/JellyOutlineSelected

@export var target_location: Vector2 = Vector2(0,0)
@export var selected: bool = false
@export var speed: float = 1000


@export_enum("ENGINEER", "COMMUNICATOR", "FARMER", "NONE","SCIENTIST") var character_class: int
var class_animation_array = [
	"become_engineer",
	"become_communicator",
	"become_farmer",
	"become_blank",
	"become_scientist"
]


func _ready() -> void:
	state_chart.send_event(class_animation_array[character_class])
	pass
	

func _physics_process(delta: float) -> void:
	if global_position.distance_to(target_location) > 15:
		print(global_position.distance_to(target_location))
		velocity = (target_location-global_position).normalized()*speed
		if global_position.x - target_location.x > 0:
			print("move left")
			state_chart.send_event("move_left")
		else:
			state_chart.send_event("move_right")
		#print(target_location)
		#print(velocity)
		move_and_slide()
	if global_position.distance_to(target_location)<15 && global_position.distance_to(target_location) > 1:
		print("nearby")
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
		if selected && event.button_index == MOUSE_BUTTON_RIGHT && event.pressed == false:
			#print("Mouse Click/Unclick at: ", event.position)
			target_location = event.position
			#print(event.button_index)
			#print(event.pressed)
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed == false:
			if jelly_outline.visible:
				selected = true
				jelly_outline_selected.visible=true
			if not jelly_outline.visible && not event.shift_pressed:
				selected = false
				jelly_outline_selected.visible=false
			
		if event.button_index == MOUSE_BUTTON_MIDDLE && event.pressed == false && selected:
			state_chart.send_event(class_animation_array[character_class])
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && selected:
			character_class -= 1
			character_class %= len(class_animation_array)
			state_chart.send_event(class_animation_array[character_class])
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && selected:
			character_class += 1
			character_class %= len(class_animation_array)
			state_chart.send_event(class_animation_array[character_class])
			
	#elif event is InputEventMouseMotion:
		#print("Mouse Motion at: ", event.position)

func entered_building_radius(area):
	#if character_class == 
	#state_chart.send_event("entered_building_radius")
	pass

func _on_area_2d_entered(area):
	pass




func _on_mouse_entered() -> void:
	jelly_outline.visible = true
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	jelly_outline.visible = false
	pass # Replace with function body.
