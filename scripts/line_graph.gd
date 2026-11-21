class_name LineGraph
extends Control

@export var line_color := Color.RED
@export var line_width := 2.0
@export var padding := 10.0
@export var x_window := 10.0
@export var min_y := 0.0
@export var max_y := 1.0
@export var auto_scale := true

var _samples := PackedVector2Array()


func add_sample(x: float, y: float) -> void:
	_samples.append(Vector2(x, y))
	
	var cutoff := x - x_window
	var drop := 0
	while drop < _samples.size() - 1 and _samples[drop].x < cutoff:
		drop += 1
	if drop > 0:
		_samples = _samples.slice(drop)
	
	queue_redraw()


func clear() -> void:
	_samples.clear()
	queue_redraw()


func _draw() -> void:
	if _samples.size() < 2:
		return
	
	var area := Rect2(Vector2(padding, padding), size - Vector2(padding, padding) * 2.0)
	var t_end := _samples[-1].x
	var t_start := t_end - x_window
	
	var top := max_y
	if auto_scale:
		top = min_y + 1.0
		for s in _samples:
			top = maxf(top, s.y)
	var span := top - min_y
	
	var points := PackedVector2Array()
	points.resize(_samples.size())
	for i in _samples.size():
		var s := _samples[i]
		points[i] = Vector2(
			area.position.x + (s.x - t_start) / x_window * area.size.x,
			area.end.y - (s.y - min_y) / span * area.size.y
		)
	
	draw_polyline(points, line_color, line_width, true)
