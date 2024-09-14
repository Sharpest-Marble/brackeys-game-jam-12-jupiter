extends Node2D

class_name Building
@export_category("Building Info")
@export var building_name: String = "science_building"
@export_enum("Mine", "Comms", "Farm","Science", "Upgrade","ShipEnd","Ship","ShipEngine","Ark","None") var building_type: int
@export var building_texture: Texture2D
@export var building_process_time: float = 5
@export var layer_active: int = 17

@export_category("Resource Production")
@export var resource_qty: int = 1
@export var max_workers: int = 5
@export var worker_efficiency: float = 0.1
@export_enum("SCIENCE","METAL","FOOD","COMM") var resource_produced: int
@export_enum("ENGINEER", "COMMUNICATOR", "FARMER", "NONE","SCIENTIST") var worked_by: int
@export var comm_cost: int = 5

@onready var worker_association: Area2D = $WorkerAssociation
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var snap_to: Area2D = $SnapTo
@onready var worker_association_collision_shape: CollisionShape2D = $WorkerAssociation/CollisionShape2D
@onready var static_body_2d_collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var snap_to_collision_shape: CollisionShape2D = $SnapTo/CollisionShape2D
@onready var building_sprite: Sprite2D = $StaticBody2D/BuildingSprite
@onready var timer: Timer = $Timer
var resource_cost: Array[int]

var current_workers: int = 0
# TODO: add upgrade stuff so these increase the rate of production
const POSSIBLE_UPGRADES: Array[String] = [
	"WorkerStations",
	"Overclocking",
	"ResourceBoost",
	"ByproductHarvester"
]
enum building_types {
	Mine, 
	Comms, 
	Farm,
	Science, 
	Upgrade,
	ShipEnd,
	Ship,
	ShipEngine,
	Ark,
	None	
}
enum resources {
	SCIENCE,
	METAL,
	FOOD,
	COMM
}
var associated_workers = []
var resource_delta_delta: Array[float] = [
	0,0,0,0
]
var placeable: bool = false
var placed: bool = false

signal produced_resource(resource_type: int, resource_qty: int)
signal update_resouce_delta(resource_delta_delta:Array[float])
signal deselect_worker(worker_entered)
signal negotiate(rate,comm_cost)

func _ready() -> void:
	if building_type != building_types.None:
		worker_association_collision_shape.set_disabled(true)
		static_body_2d_collision_shape.set_disabled(true)
		snap_to_collision_shape.set_disabled(false)
	else:
		snap_to_collision_shape.set_disabled(true)
	building_sprite.texture = building_texture
	name = building_name
	timer.wait_time = building_process_time
	update_layers_active(layer_active)
	building_sprite.set_self_modulate(Color(0.1,0.1,01,0.5))
	worker_association.body_entered.connect(_on_worker_association_body_entered)
	worker_association.body_exited.connect(_on_worker_association_body_exited)
	#if building_type == building_types.None:
		#place_building()

func _physics_process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not placed:
		if event is InputEventMouseMotion && not placeable:
			global_position = event.global_position

func update_worker_production_rate(worker_delta: int):
	var worker_resource_delta_delta: Array[float] = [
		0,0,0,0
	]
	if building_type != building_types.None:
		worker_resource_delta_delta[resource_produced] = worker_efficiency*worker_delta*float(resource_qty)/float(timer.wait_time)
	#print(worker_resource_delta_delta)
	if building_type == building_types.None:
		var delta_comm_cost:int = float(worker_delta) * float(comm_cost) /timer.wait_time
		worker_resource_delta_delta[resource_produced] = -delta_comm_cost
		
	update_resouce_delta.emit(worker_resource_delta_delta)

func update_production_rate():
	if building_type in range(0,4):
		resource_delta_delta[resource_produced] = float(resource_qty) / float(timer.wait_time)
		update_resouce_delta.emit(resource_delta_delta)
		

func update_layers_active(current_layer: int):
	layer_active = current_layer
	for layer in range(1,32):
		snap_to.set_collision_layer_value(layer,false)
		snap_to.set_collision_mask_value(layer,false)
	snap_to.set_collision_layer_value(layer_active,true)
	snap_to.set_collision_mask_value(layer_active,true)

func place_building():
	placed = true
	timer.start()
	snap_to.visible = false
	worker_association_collision_shape.set_disabled(false)
	#static_body_2d_collision_shape.set_disabled(false)
	snap_to_collision_shape.set_disabled(true)
	worker_association.set_collision_layer_value(layer_active,true)
	worker_association.set_collision_mask_value(layer_active,true)
	#static_body_2d.set_collision_layer_value(layer_active,true)
	#static_body_2d.set_collision_mask_value(layer_active,true)
	building_sprite.set_self_modulate(Color(1,1,1,1))
	update_production_rate()
	


func _on_timer_timeout() -> void:
	if building_type in range(0,4):
		var resource_qty_sent = resource_qty * (1 + worker_efficiency*current_workers)
		produced_resource.emit(resource_produced,resource_qty_sent)
	if building_type == building_types.None:
		negotiate.emit(current_workers*worker_efficiency, current_workers*comm_cost)
	#print(name + " timer timeout")
	pass


func _on_worker_association_body_entered(body: Node2D) -> void:
	if body is JellyPerson && ((current_workers < max_workers && building_type in range(0,4)) or building_type == building_types.None):
		assert(body is JellyPerson)
		#spread out the workers a bit
		# this doesnt work super well but eh
		deselect_worker.emit(body)
		var circle_offset:Vector2 = 50*Vector2(sin(-2*(current_workers*PI)/max_workers),cos(2*(current_workers*PI)/max_workers))
		#print(circle_offset)
		body.target_location = global_position + circle_offset
		body.set_collision_mask_value(Globals.current_layer,false)
		if building_type == building_types.None:
			body.target_location = global_position + Vector2(10*current_workers/2-200,10*(current_workers%2))
			await get_tree().create_timer(1).timeout
		body.state_chart.send_event.call_deferred(building_name+"_entered")
		current_workers+=1
		associated_workers.append(body)
		update_worker_production_rate(1)

func replace_worker():
	for body in worker_association.get_overlapping_bodies():
		_on_worker_association_body_entered(body)

func _on_worker_association_body_exited(body: Node2D) -> void:
	if body is JellyPerson && (building_type in range(0,4) or building_type == building_types.None) && body in associated_workers:
		print(body)
		body.jelly_person_body.scale = Vector2(0.2,0.2)
		current_workers -= 1
		associated_workers[associated_workers.find(body)] = null
		print(current_workers)
		update_worker_production_rate(-1)
		body.state_chart.send_event("idle")
	#replace_worker()
		
