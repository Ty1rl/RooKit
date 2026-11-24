class_name JadeCoin
extends Node

signal updated(gained: float, total: float)

@export var stream_status: StreamStatus
@export var punch_clock: PunchClock
@export var step: float = 0.01
@export var rate: int = 60

const CONFIG_PATH = "user://jade_coin.cfg"
const MAX_HISTORY := 60

var history := PackedVector2Array()

var gained: float = 0
var total: float = 0


func _ready() -> void:
	_load_config()
	_poll_loop.call_deferred() # deferred so graphs have time to connect


func _poll_loop() -> void:
	while is_inside_tree():
		_update()
		await get_tree().create_timer(rate).timeout


func _update() -> void:
	gained += step * punch_clock.count
	total += step * punch_clock.count
	
	history.append(Vector2(Time.get_ticks_msec() / (1000.0 * rate), total))
	if history.size() > MAX_HISTORY:
		history.remove_at(0)
	
	updated.emit(gained, total)
	_save_config()


func _save_config() -> void:
	var config = ConfigFile.new()
	
	config.set_value("jade_coin", "total", total)
	
	var error = config.save(CONFIG_PATH)
	
	if error != OK:
		push_error("Failed to save JadeCoin!")


func _load_config() -> void:
	var config = ConfigFile.new()
	var error = config.load(CONFIG_PATH)
	
	if error == OK:
		total = config.get_value("jade_coin", "total", 0.0)
