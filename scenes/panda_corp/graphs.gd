extends Control

@export var stream_status: StreamStatus
@export var jade_coin: JadeCoin

@onready var veiwer_line_graph: LineGraph = $VeiwerLineGraph
@onready var jade_coin_line_graph: LineGraph = $JadeCoinLineGraph

var viewer_x: int = 0
var jade_x: int = 0


func _ready() -> void:
	stream_status.stream_stats_updated.connect(_on_stream_stats_updated)
	jade_coin.updated.connect(_on_jade_coin_updated)


func _on_stream_stats_updated(stats: Dictionary):
	var viewer_count: int = stats.get("viewer_count")
	veiwer_line_graph.add_sample(viewer_x, viewer_count)
	viewer_x += 1


func _on_jade_coin_updated(_gained: float, total: float):
	jade_coin_line_graph.add_sample(jade_x, total)
	jade_x += 1
