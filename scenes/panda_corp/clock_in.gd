extends Node2D

@export var stream_status: StreamStatus
@export var punch_clock: PunchClock
@export var jade_coin: JadeCoin

@onready var path_queue: PathQueue = $PathQueue
@onready var count_label: RichTextLabel = %CountLabel
@onready var jade_coin_total: RichTextLabel = %JadeCoinTotal
@onready var jade_coin_gain: RichTextLabel = %JadeCoinGain


const panda_scene: PackedScene = preload("uid://cf7g3u44tc1gq")


func _enter_tree() -> void:
	var graphs: Control = %Graphs
	graphs.stream_status = stream_status
	graphs.jade_coin = jade_coin


func _ready() -> void:
	jade_coin.updated.connect(_on_jade_coin_updated)
	punch_clock.clock_in.connect(_on_clock_in)
	count_label.text = punch_clock.format_count(punch_clock.count)
	jade_coin_total.text = "[b]" + str(jade_coin.total) + "[/b]"
	jade_coin_gain.text = "[b] + " + str(jade_coin.gained) + "[/b]"


func _on_clock_in(username: String, count: String):
	path_queue.enqueue(panda_scene, 0, {"username": username})
	count_label.text = count

func _on_jade_coin_updated(gained: float, total: float):
	jade_coin_total.text = "[b]" + str(total) + "[/b]"
	jade_coin_gain.text = "[b] + " + str(gained) + "[/b]"
