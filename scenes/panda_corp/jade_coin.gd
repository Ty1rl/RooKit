class_name JadeCoin
extends Node

signal updated(gained: float, total: float)

@export var stream_status: StreamStatus
@export var punch_clock: PunchClock
@export var step: float = 0.01
@export var rate: int = 60

const CONFIG_PATH = "user://jada_coin.cfg"

var gained: float = 0
var total: float = 0


func _ready() -> void:
	_poll_loop()


func _poll_loop() -> void:
	while is_inside_tree():
		_update()
		await get_tree().create_timer(rate).timeout


func _update() -> void:
	gained += step * punch_clock.count
	total += step * punch_clock.count
	updated.emit(gained, total)


func save_settings() -> void:
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
