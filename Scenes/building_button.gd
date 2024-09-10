extends Control


@onready var button: Button = $VBoxContainer/Button
@onready var rich_text_label: RichTextLabel = $VBoxContainer/RichTextLabel
const ICON = preload("res://icon.svg")

@export var building: PackedScene
@export var building_texture: Texture2D = ICON
@export var button_text: String = "test"
@export var button_name: String = "test_name"
#@export var text_effect: RichTextEffect = RichTextEffect.new()

signal button_make_building(building)

func _ready() -> void:
	if building_texture:
		button.icon = building_texture
	if button_text:
		rich_text_label.text = button_text
	if button_name:
		button.name = button_name
	


func _on_button_pressed() -> void:
	button_make_building.emit(building)
	print(button.name+"_pressed")
	pass # Replace with function body.
