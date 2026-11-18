extends Node2D

@export var quiet_db: float = -38.0
@export var loud_db: float = -8.0
@export var attack_speed: float = 18.0
@export var release_speed: float = 4.0

@onready var left_arm: Sprite2D = $BotAml
@onready var right_arm: Sprite2D = $BotAmr
@onready var body: Sprite2D = $BotBd
@onready var bottom_head: Sprite2D = $BotBothead
@onready var top_head: Sprite2D = $BotTophead

var _bus_index: int
var speech_energy: float = 0.0


func _ready() -> void:
	_bus_index = AudioServer.get_bus_index("Master")


func _process(delta: float) -> void:
	var intensity := _get_intensity(delta)
	
	left_arm.rotation = deg_to_rad(-20.0 * intensity)
	right_arm.rotation = deg_to_rad(20.0 * intensity)
	body.position.y = -5.0 * intensity
	bottom_head.position.y = -10.0 * intensity
	top_head.position.y = -40.0 * intensity
	top_head.rotation = deg_to_rad(-20.0 * intensity)


func _get_intensity(delta: float) -> float:
	var left_db := AudioServer.get_bus_peak_volume_left_db(_bus_index, 0)
	var right_db :=AudioServer.get_bus_peak_volume_right_db(_bus_index, 0)
	var peak_db := maxf(left_db, right_db)
	
	var target_energy := clampf(inverse_lerp(quiet_db, loud_db, peak_db), 0.0, 1.0)
	
	# Suppress very quiet noise
	if target_energy < 0.03:
		target_energy = 0.0
	
	var speed := attack_speed if target_energy > speech_energy else release_speed
	
	speech_energy = lerpf(speech_energy, target_energy, 1.0 - exp(-speed * delta))
	
	# Small volume changes less pronounced
	return pow(speech_energy, 1.25)
