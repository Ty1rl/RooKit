extends Node2D

@export var twitch_chat: TwitchChat
@export var trigger_string := "rooBongos"
@export var projectile_scene: PackedScene
@export var projectile_spawn_point: Marker2D


@onready var bongo_bar: ProgressBar = %BongoBar

var _elapsed: float = 0.0

func _ready() -> void:
	twitch_chat.message_received.connect(_on_chat_message_received)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= (1.0 - bongo_bar.value):
		_elapsed = 0.0
		spawn_projectile()
	
	if bongo_bar.value >= 0.0:
		bongo_bar.value -= 0.01


func _on_chat_message_received(chat_message: TwitchChatMessage) -> void:
	if trigger_string not in chat_message.message.text:
		return
	
	bongo_bar.value += 0.02


func spawn_projectile() -> void:
	if projectile_scene == null or projectile_spawn_point == null:
		return

	var projectile := projectile_scene.instantiate() as RigidBody2D
	projectile.global_position = projectile_spawn_point.global_position
	add_child(projectile)
