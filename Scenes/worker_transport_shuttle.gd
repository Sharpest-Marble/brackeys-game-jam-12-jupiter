extends Sprite2D
class_name WorkerTransportShuttle

@onready var area_2d: Area2D = $Area2D
var workers_in_shuttle: int = 0
func hoover_workers():
	for body in area_2d.get_overlapping_bodies():
		if body is JellyPerson:
			body.queue_free()
			workers_in_shuttle += 1
