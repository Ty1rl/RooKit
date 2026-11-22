class_name LineGraph
extends Control

@export var line_color := Color.RED
@export var line_width := 5.0
@export var padding := 0.0
@export var window := 10
@export var fill := false

var _samples := PackedVector2Array()
var _origin := Vector2.ZERO


func add_sample(x: float, y: float) -> void:
	if _samples.is_empty():
		_origin = Vector2(x, y)
	
	_samples.append(Vector2(x, y))
	
	if _samples.size() > window:
		_samples.remove_at(0)
	
	queue_redraw()


func clear() -> void:
	_samples.clear()
	queue_redraw()


func _draw() -> void:
	if _samples.size() < 2:
		return
	
	var area := Rect2(Vector2.ZERO, size).grow(-padding)
	var x_range := _get_range(Vector2.AXIS_X, fill)
	var y_range := _get_range(Vector2.AXIS_Y, fill)
	
	var start := Vector2(x_range.x, y_range.x)
	var span := Vector2(x_range.y, y_range.y).max(Vector2(0.00001, 0.00001))
	var px_per_unit := area.size / span
	
	var points := PackedVector2Array()
	points.resize(_samples.size())
	for i in _samples.size():
		var p := (_samples[i] - start) * px_per_unit
		points[i] = Vector2(area.position.x + p.x, area.end.y - p.y)
	
	draw_polyline(points, line_color, line_width, true)


## Vector2(start, span) for one axis.
func _get_range(axis: Vector2.Axis, fit: bool) -> Vector2:
	var lo := _samples[-1][axis]
	var hi := lo
	
	for s: Vector2 in _samples:
		lo = minf(lo, s[axis])
		hi = maxf(hi, s[axis])
	
	if fit:
		return Vector2(lo, hi - lo)
	
	var span := maxf(window, hi - lo)
	return Vector2(clampf(_origin[axis], hi - span, lo), span)
