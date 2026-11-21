extends PanelContainer

@export var stream_status: StreamStatus
@export var punch_clock: PunchClock
@export var jade_coin: JadeCoin

@onready var api_label: Label = %APILabel
@onready var stream_label: Label = %StreamLabel
@onready var viewers_label: Label = %ViewersLabel
@onready var clockin_label: Label = %ClockinLabel
@onready var jade_coin_gain_label: Label = %JadeCoinGainLabel
@onready var jade_coin_total_label: Label = %JadeCoinTotalLabel


func _ready() -> void:
	stream_status.stream_stats_updated.connect(_on_stream_stats_updated)
	punch_clock.clock_in.connect(_on_clock_in)
	jade_coin.updated.connect(_on_jade_coin_updated)


func _on_jade_coin_updated(gained: float, total: float) -> void:
	jade_coin_gain_label.text = "Gained: " + str(gained)
	jade_coin_total_label.text = "Total: " + str(total)


func _on_clock_in(_username: String, _count: String) -> void:
	clockin_label.text = "Clocked in: " + str(punch_clock.count)


func _on_stream_stats_updated(stats: Dictionary) -> void:
	var is_live: bool = stats.get("is_live")
	var viewer_count: int = stats.get("viewer_count")
	
	if stream_status.current_user_id:
		api_label.text = "API: Connected"
	else:
		api_label.text = "API: Disconnected"
	
	if is_live:
		stream_label.text = "Stream: Online"
		viewers_label.text = "Viewers: " + str(viewer_count)
	else:
		stream_label.text = "Stream: Offline"
		viewers_label.text = "Viewers: 0"
