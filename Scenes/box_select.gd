extends Node2D
@export var dragging:bool = false
@export var drag_start: Vector2 = Vector2.ZERO
@export var drag_end: Vector2 = Vector2.ZERO
func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, drag_end - drag_start),
				Color.NAVY_BLUE, false, 2.0)
		draw_rect(Rect2(drag_start, drag_end - drag_start),
				Color(0,0,1,0.1),true)
