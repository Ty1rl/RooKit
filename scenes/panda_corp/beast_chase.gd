extends Path2D

@export var speed: float = 512.0
@export_range(0.0, 1.0, 0.05) var trigger_chance: float = 0.3
@export_range(0.0, 1.0, 0.05) var chance_increase: float = 0.1
@export var trigger_interval: float = 30.0

@onready var _follow: PathFollow2D = $BeastChaseFollow
@onready var _sprite: AnimatedSprite2D = $BeastChaseFollow/BeastChaseSprite

var _path_length: float
var _current_chance: float
var _direction: int = 1
var _active: bool = false


func _ready() -> void:
	_path_length = curve.get_baked_length()
	_current_chance = trigger_chance
	
	_follow.loop = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
	var timer := Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.wait_time = trigger_interval
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)


func _process(delta: float) -> void:
	_follow.progress = clampf(_follow.progress + speed * _direction * delta, 0.0, _path_length)
	
	if _direction > 0 and _follow.progress >= _path_length:
		_direction = -1
		_sprite.flip_h = true
		_stop_chase()
	elif _direction < 0 and _follow.progress <= 0.0:
		_direction = 1
		_sprite.flip_h = false
		_stop_chase()


func _on_timer_timeout() -> void:
	if _active:
		return
	
	if randf() < _current_chance:
		_current_chance = trigger_chance
		_start_chase()
	else:
		_current_chance = minf(_current_chance + chance_increase, 1.0)


func _start_chase() -> void:
	_active = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT


func _stop_chase() -> void:
	_active = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
