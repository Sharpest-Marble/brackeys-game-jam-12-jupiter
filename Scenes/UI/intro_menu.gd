extends Control

class_name IntroMenu

@onready var intro_title: Label = $"MarginContainer/PanelContainer/VBoxContainer/Intro Title"
@onready var reference_title: Label = $MarginContainer/PanelContainer/VBoxContainer/ReferenceTitle
@onready var worker_reference_title: Label = $MarginContainer/PanelContainer/VBoxContainer/WorkerReferenceTitle
@onready var icon_reference_title: Label = $MarginContainer/PanelContainer/VBoxContainer/IconReferenceTitle


@onready var button_placeholder: Control = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/button_placeholder
@onready var button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Button
@onready var button_2: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Button2
@onready var button_placeholder_2: Control = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/button_placeholder2
@onready var button_3: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Button3

@onready var page_1: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/Page1
@onready var page_2_vbox: VBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/Page2Vbox
@onready var v_box_container_2: VBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer2
@onready var v_box_container: VBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer
@onready var building_reference_hbox: HBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/BuildingReferenceHbox
@onready var worker_reference_vbox: VBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/WorkerReferenceVbox
@onready var resource_icons_vbox: VBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/ResourceIconsVbox


@onready var pages:Array = [
	[intro_title,page_1],
	[intro_title,page_2_vbox],
	[intro_title,v_box_container_2],
	[intro_title,v_box_container],
	[reference_title,building_reference_hbox],	
	[worker_reference_title,worker_reference_vbox],	
	[icon_reference_title,resource_icons_vbox],
]
var current_page:int = 0


func _ready() -> void:
	get_tree().paused = true
	show_page(0)
		
func show_page(page_to_show):
	if page_to_show > 0:
		print(page_to_show)
		button.show()
		button_placeholder.hide()
	else:
		button_placeholder.show()
		button.hide()
	if page_to_show < pages.size():
		button_2.show()
		button_placeholder_2.hide()
	else:
		button_2.hide()
		button_placeholder_2.show()

	for page in pages:
		for sub_page in page:
			sub_page.hide()
	for sub_page:Control in pages[page_to_show]:
		sub_page.show()

func show_reference_pages():
	show()
	print("Showing Reference Pages")
	current_page = 4
	show_page(4)

func _on_button_pressed() -> void:
	if current_page <pages.size():
		button_2.show()
		button_placeholder_2.hide()
	current_page-=1
	if current_page == 0:
		button.hide()
		button_placeholder.visible=true
	for page in pages:
		for sub_page in page:
			sub_page.hide()
	for sub_page:Control in pages[current_page]:
		sub_page.show()


func _on_button_2_pressed() -> void:
	if current_page == 0:
		button.show()
		button_placeholder.hide()
	current_page+=1
	if current_page ==pages.size() - 1:
		button_2.hide()
		button_placeholder_2.show()
	for page in pages:
		for sub_page in page:
			sub_page.hide()
	for sub_page:Control in pages[current_page]:
		sub_page.visible = true


func _on_button_3_pressed() -> void:
	hide()
	get_tree().paused = false
