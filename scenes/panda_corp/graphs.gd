extends Control

@export var stream_status: StreamStatus
@export var jade_coin: JadeCoin

@onready var veiwer_line_graph: LineGraph = $VeiwerLineGraph
@onready var jade_coin_line_graph: LineGraph = $JadeCoinLineGraph


func _ready() -> void:
	stream_status.stream_stats_updated.connect(_on_stream_stats_updated)
	jade_coin.updated.connect(_on_jade_coin_updated)
	
	for s in stream_status.viewer_history:
		veiwer_line_graph.add_sample(s.x, s.y)
	
	for s in jade_coin.history:
		jade_coin_line_graph.add_sample(s.x, s.y)


func _on_stream_stats_updated(stats: Dictionary):
	var viewer_count: int = stats.get("viewer_count")
	veiwer_line_graph.add_sample(Time.get_ticks_msec() / (1000.0 * stream_status.poll_rate), viewer_count)


func _on_jade_coin_updated(_gained: float, total: float):
	jade_coin_line_graph.add_sample(Time.get_ticks_msec() / (1000.0 * jade_coin.rate), total)
