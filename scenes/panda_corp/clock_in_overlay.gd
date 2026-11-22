extends Node2D

@export var punch_clock: PunchClock

@onready var path_queue: PathQueue = $PathQueue
@onready var count_label: RichTextLabel = %CountLabel

const panda_scene: PackedScene = preload("uid://cf7g3u44tc1gq")

var _tween: Tween


func _ready() -> void:
	punch_clock.clock_in.connect(_on_clock_in)
	
	count_label.text = punch_clock.format_count(punch_clock.count)
	
	visible = false
	slide_out()


func _on_clock_in(username: String, count: String):
	path_queue.enqueue(panda_scene, 0, {"username": username, "size": 0.5})
	count_label.text = count


func slide_in() -> void:
	visible = true
	
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = create_tween().set_parallel(false)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "position", Vector2.ZERO, 0.3)


func slide_out() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = create_tween().set_parallel(false)
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "position", Vector2(0, 300), 0.3)
	
	await _tween.finished
	visible = false


func _on_path_queue_active_queue_started() -> void:
	slide_in()


func _on_path_queue_active_queue_emptied() -> void:
	slide_out()
