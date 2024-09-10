extends Node2D

@export var building_name: String = "building_test"
@export var building_texture: Texture2D
@export var building_process_time: int = 5

@onready var building_sprite: Sprite2D = $StaticBody2D/BuildingSprite
@onready var timer: Timer = $Timer

var placed: bool = false

func _ready() -> void:
	building_sprite.texture = building_texture
	name = building_name
	timer.wait_time = building_process_time
	building_sprite.set_self_modulate(Color(0.1,0.1,01,0.5))

func _physics_process(delta: float) -> void:

	pass

func _input(event: InputEvent) -> void:
	if not placed:
		if event is InputEventMouseMotion:
			global_position = event.global_position
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT && event.pressed == false:
				place_building()

func place_building():
	placed = true	
	timer.start()
	building_sprite.set_self_modulate(Color(1,1,1,1))


func _on_timer_timeout() -> void:
	print(name + " timer timeout")
	pass # Replace with function body.
