class_name TTSVoice
extends Node

signal message_started(text: String)
signal speech_started
signal speech_ended
signal queue_emptied

var player := AudioStreamPlayer.new()
var queue: Array[String] = []
var busy := false

var _voice := ""


func _ready() -> void:
	add_child(player)
	player.finished.connect(_on_player_finished)
	
	var voices := DisplayServer.tts_get_voices_for_language("en")
	if not voices.is_empty():
		_voice = voices[0]
	
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_STARTED, _on_tts_started)
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_ENDED, _on_tts_ended)
	DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_CANCELED, _on_tts_ended)


func speak(text: String) -> void:
	queue.append(text)
	_next()


func _next() -> void:
	if busy or queue.is_empty():
		return
	
	busy = true
	message_started.emit(queue[0])
	
	if _voice.is_empty():
		_finish_current()
		return
	
	DisplayServer.tts_speak(queue[0], _voice)


func _on_player_finished() -> void:
	_finish_current()


func _on_tts_started(_id: int) -> void:
	speech_started.emit()


func _on_tts_ended(_id: int) -> void:
	_finish_current()


func _finish_current() -> void:
	if not busy:
		return
	
	queue.pop_front()
	busy = false
	speech_ended.emit()
	
	if queue.is_empty():
		queue_emptied.emit()
	else:
		_next()
