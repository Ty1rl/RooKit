class_name  StreamStatus
extends Node

signal stream_stats_updated(stats: Dictionary)
signal stream_stats_error(message: String)

@export var poll_rate: int = 60

const MAX_HISTORY := 60

var viewer_history := PackedVector2Array()

var twitch_api: TwitchAPI
var current_user_id: String


func _ready() -> void:
	var service = TwitchService.instance
	
	twitch_api = service.get_node("API")
	
	var user: TwitchUser = await service.get_current_user()
	
	if user == null:
		push_error("Could not retrieve Twitch user.")
		return
	
	current_user_id = user.id
	#current_user_id = "40972890"
	
	_poll_loop()


func _poll_loop() -> void:
	while is_inside_tree():
		await refresh_stream_stats()
		await get_tree().create_timer(poll_rate).timeout


func refresh_stream_stats() -> void:
	var response = await twitch_api.request("/streams?user_id=%s" % current_user_id, HTTPClient.METHOD_GET)
	
	if response.error or response.response_code != 200:
		stream_stats_error.emit("Twitch API request failed: %s" % response.response_code)
		return
	
	var payload = JSON.parse_string(response.response_data.get_string_from_utf8())
	
	if typeof(payload) != TYPE_DICTIONARY:
		stream_stats_error.emit("Invalid Twitch API response.")
		return
	
	var streams: Array = payload.get("data", [])
	
	var stats := {
		"is_live": false,
		"viewer_count": 0,
		"title": "",
		"game_name": "",
		"started_at": "",
		"stream_id": ""
	}
	
	if not streams.is_empty():
		var stream: Dictionary = streams[0]
	
		stats["is_live"] = true
		stats["viewer_count"] = int(stream.get("viewer_count", 0))
		stats["title"] = stream.get("title", "")
		stats["game_name"] = stream.get("game_name", "")
		stats["started_at"] = stream.get("started_at", "")
		stats["stream_id"] = stream.get("id", "")
	
	viewer_history.append(Vector2(Time.get_ticks_msec() / (1000.0 * poll_rate), stats["viewer_count"]))
	if viewer_history.size() > MAX_HISTORY:
		viewer_history.remove_at(0)
	
	stream_stats_updated.emit(stats)


func get_current_viewer_count(user_id: String) -> int:
	var opt := TwitchGetStreams.Opt.new()
	opt.user_id = [user_id]
	
	var response: TwitchGetStreams.Response = await TwitchAPI.instance.get_streams(opt)
	
	if response == null or response.data.is_empty():
		return 0
		
	return response.data[0].viewer_count
