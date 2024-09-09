extends CharacterBody2D

@onready var modifier: Sprite2D = $JellyPersonBody/modifier
@onready var animation_player: AnimationPlayer = $JellyPersonBody/AnimationPlayer
@onready var modifier_animations: AnimationPlayer = $JellyPersonBody/modifier/ModifierAnimations

var target_location: Vector2 = Vector2(0,0)
@export var selected: bool = false
@export var speed: float = 30000


@export_enum("ENGINEER", "COMMUNICATOR", "FARMER", "NONE","SCIENTIST") var character_class: int
var class_animation_array = [
	"Engineer_modifier",
	"Communicator_modifier",
	"Farmer_modifier",
	"1_modifier",
	"Science_modifier"
]


func _ready() -> void:
	animation_player.play("hover")
	pass
	


func _physics_process(delta: float) -> void:
	if position.distance_to(target_location) > 5:
		velocity = (target_location-position).normalized()*delta*speed
		print(target_location)
		#print(velocity)
		move_and_slide()
	pass
	# figure out how to get mouse button input
	
	
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if selected && event.button_index == 2 && event.pressed == false:
			#print("Mouse Click/Unclick at: ", event.position)
			target_location = event.position
			#print(event.button_index)
			#print(event.pressed)
		if event.button_index == 1 && event.pressed == false:
			if position.distance_to(event.position) <50:
				selected = true
		if event.button_index == 3 && event.pressed == false:
			modifier_animations.play("animations/"+class_animation_array[character_class])
			pass
	#elif event is InputEventMouseMotion:
		#print("Mouse Motion at: ", event.position)
