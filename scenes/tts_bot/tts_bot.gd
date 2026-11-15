extends Node2D

@export var shown_marker: Marker2D
@export var hidden_marker: Marker2D
@export var linger_time := 0.3

@onready var speaker: PhononSpeaker = $PhononSpeaker
@onready var user_label: RichTextLabel = $UserLabel
@onready var message_label: RichTextLabel = $MessageLabel
@onready var body: Node2D = $Body

@onready var _sprite_effect := SpriteFrameEffect.new()

var _tween: Tween


func _ready() -> void:
	speaker.loaded.connect(func(): speaker.speak("TTS ready"))
	speaker.load_model()
	speaker.started.connect(_on_speech_started)
	speaker.finished.connect(_on_speech_ended)
	
	position = hidden_marker.position
	visible = false
	
	var main : Node = get_parent()
	main.subscription_message.received.connect(_on_subscription_message)


func _on_subscription_message(data: Dictionary) ->void:
	var username: String = data["user_name"]
	var message: String = data["message"]["text"]
	
	user_label.install_effect(_sprite_effect)
	user_label.text = _sprite_effect.prepare_message("[b]" + username + "[/b]", user_label)
	
	message_label.install_effect(_sprite_effect)
	message_label.text = _sprite_effect.prepare_message(message, message_label)
	
	speaker.speak(message)


func _on_speech_started() -> void:
	_slide_in()


func _on_speech_ended() -> void:
	_slide_out()


func _slide_in() -> void:
	if _tween:
		_tween.kill()
	
	visible = true
	_tween = create_tween()
	_tween.tween_property(self, "position", shown_marker.position, 0.3)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)


func _slide_out() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_interval(linger_time)
	_tween.tween_property(self, "position", hidden_marker.position, 0.3)
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_callback(func(): visible = false)
