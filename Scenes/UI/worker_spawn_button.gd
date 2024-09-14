extends MarginContainer

@export  var resource_costs: Array[int] = [0,0,0,0]

@onready var worker_resource_cost_label: RichTextLabel = %WorkerResourceCostLabel

const SCIENCE_ICON = preload("res://Assets/UI/science_ICON.png")
const COMM_ICON = preload("res://Assets/UI/comm_ICON.png")
const CORE_METAL_ICON = preload("res://Assets/UI/core_metal_ICON.png")
const PLANT_ICON = preload("res://Assets/UI/plant_ICON.png")
const RESOURCE_ICONS = [
	SCIENCE_ICON,
	CORE_METAL_ICON,
	PLANT_ICON,
	COMM_ICON
]
enum resources {
	SCIENCE,
	METAL,
	FOOD,
	COMM
}

signal spawn_worker(resource_costs:Array[int])

func _ready() -> void:
	worker_resource_cost_label.append_text("Recruit Worker\n")
	for i in resource_costs.size():
		worker_resource_cost_label.append_text("%d "%resource_costs[i])
		worker_resource_cost_label.add_image(RESOURCE_ICONS[i],24)
		if i ==1:
			worker_resource_cost_label.append_text("\n")
	

func _on_worker_spawn_button_pressed() -> void:
	spawn_worker.emit(resource_costs)
