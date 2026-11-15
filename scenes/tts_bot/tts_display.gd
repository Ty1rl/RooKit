class_name TTSDisplay
extends Node2D

@export var shown_marker: Marker2D
@export var hidden_marker: Marker2D
@export var linger_time := 0.3

@onready var user_label: RichTextLabel = $UserLabel
@onready var message_label: RichTextLabel = $MessageLabel
@onready var body: Node2D = $Body

var _sprite_effect := SpriteFrameEffect.new()
var _tween: Tween


func _ready() -> void:
	user_label.install_effect(_sprite_effect)
	message_label.install_effect(_sprite_effect)
	
	position = hidden_marker.position
	visible = false


func show_message(message: TTSMessage) -> void:
	user_label.text = _sprite_effect.prepare_message("[b]" + message.username + "[/b]", user_label)
	message_label.text = _sprite_effect.prepare_message(message.text, message_label)
	
	if _tween:
		_tween.kill()
	
	visible = true
	_tween = create_tween()
	_tween.tween_property(self, "position", shown_marker.position, 0.3)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)


func hide_message(immediate := false) -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_interval(0.0 if immediate else linger_time)
	_tween.tween_property(self, "position", hidden_marker.position, 0.3)
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_callback(func(): visible = false)
