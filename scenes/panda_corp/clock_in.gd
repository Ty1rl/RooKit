extends Node2D

@export var stream_status: StreamStatus
@export var punch_clock: PunchClock
@export var jade_coin: JadeCoin

@onready var path_queue: PathQueue = $PathQueue
@onready var count_label: RichTextLabel = %CountLabel

const panda_scene: PackedScene = preload("uid://cf7g3u44tc1gq")

var _dragged: Node2D

func _enter_tree() -> void:
	var graphs: Control = %Graphs
	graphs.stream_status = stream_status
	graphs.jade_coin = jade_coin


func _ready() -> void:
	punch_clock.clock_in.connect(_on_clock_in)
	
	count_label.text = punch_clock.format_count(punch_clock.count)
	
	path_queue.character_released.connect(_on_character_released)


func _on_clock_in(username: String, count: String):
	path_queue.enqueue(panda_scene, 0, {"username": username})
	count_label.text = count


func _on_character_released(character: Node2D) -> void:
	# The click may already be over if the release was deferred.
	_dragged = character if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else null
	if not _dragged:
		_on_dropped(character)


func _process(_delta: float) -> void:
	if is_instance_valid(_dragged):
		_dragged.global_position = get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if _dragged and event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var character := _dragged
		_dragged = null
		_on_dropped(character)


func _on_dropped(character: Node2D) -> void:
	pass # Attach the NPC behavior here.
