extends Node2D

@onready var path_queue: PathQueue = $PathQueue
@onready var count_label: RichTextLabel = %CountLabel

const panda_scene: PackedScene = preload("uid://cf7g3u44tc1gq")


func _ready() -> void:
	var main : Node = get_tree().current_scene
	var punch_clock : PunchClock = main.punch_clock
	punch_clock.clock_in.connect(_on_clock_in)
	
	count_label.text = punch_clock.format_count(punch_clock.count)


func _on_clock_in(username: String, count: String):
	path_queue.enqueue(panda_scene, 0, {"username": username})
	count_label.text = count
