extends Control
class_name BuildingButton

@onready var button: Button = $VBoxContainer/Button
@onready var label: Label = $VBoxContainer/Label
@onready var costs_label: RichTextLabel = $VBoxContainer/CostsLabel
const SCIENCE_ICON = preload("res://Assets/UI/science_ICON.png")
const COMM_ICON = preload("res://Assets/UI/comm_ICON.png")
const CORE_METAL_ICON = preload("res://Assets/UI/core_metal_ICON.png")
const PLANT_ICON = preload("res://Assets/UI/plant_ICON.png")

@export var building: PackedScene
@export var resource_cost: Array[int] = [0,0,0,0]
@export var building_texture: Texture2D
@export var button_text: String = "test"
@export var button_name: String = "test_name"
#@export var text_effect: RichTextEffect = RichTextEffect.new()

enum resources {
	SCIENCE,
	METAL,
	FOOD,
	COMM
}


signal button_make_building(building,resource_cost)

func _ready() -> void:
	if building_texture:
		button.icon = building_texture
	if button_text:
		label.text = button_text
	if button_name:
		button.name = button_name
	#if building.resource_cost:
	costs_label.add_text("%d"%resource_cost[resources.SCIENCE])
	costs_label.add_image(SCIENCE_ICON,24)
	costs_label.add_text(" %d"%resource_cost[resources.METAL])
	costs_label.add_image(CORE_METAL_ICON,24)
	costs_label.add_text(" %d"%resource_cost[resources.FOOD])
	costs_label.add_image(PLANT_ICON,24)
	costs_label.add_text(" %d"%resource_cost[resources.COMM])
	costs_label.add_image(COMM_ICON,24)
	


func _on_button_pressed() -> void:
	button_make_building.emit(building, resource_cost)
	#print(button.name+"_pressed")
	pass # Replace with function body.
