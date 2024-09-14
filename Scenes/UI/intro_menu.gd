extends Control

class_name IntroMenu

@onready var page_1: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page1
@onready var page_2: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page2
@onready var page_2_2: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page2_2
@onready var page_2_3: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page2_3
@onready var page_3: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page3
@onready var page_3_grid: GridContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page3Grid
@onready var page_3_2: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page3_2
@onready var page_4: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page4
@onready var page_5: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page5
@onready var page_5_icons: HBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Page5Icons
@onready var button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Button
@onready var button_placeholder: Control = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/button_placeholder
@onready var button_2: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Button2
@onready var button_3: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Button3

@onready var pages:Array = [
	[page_1],
	[page_2],
	[page_2_2,page_2_3],	
	[page_3,page_3_grid,page_3_2],	
	[page_4],	
	[page_5,page_5_icons],
]
var current_page:int = 1


func _ready() -> void:
	get_tree().paused = true

func _on_button_pressed() -> void:
	if current_page ==pages.size():
		button_3.hide()
		button_2.show()
	current_page-=1
	if current_page < 2:
		button.hide()
		button_placeholder.visible=true
	for page in pages:
		for sub_page in page:
			sub_page.hide()
	for sub_page:Control in pages[current_page]:
		sub_page.visible = true


func _on_button_2_pressed() -> void:
	if current_page == 1:
		button.show()
		button_placeholder.hide()
	current_page+=1
	if current_page ==pages.size() - 1:
		button_3.show()
		button_2.hide()
	for page in pages:
		print(page)
		for sub_page in page:
			sub_page.hide()
	for sub_page:Control in pages[current_page]:
		sub_page.visible = true


func _on_button_3_pressed() -> void:
	hide()
	get_tree().paused = false
