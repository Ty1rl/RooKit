class_name TTSMessage
extends RefCounted

var username: String
var text: String


func _init(p_username := "", p_text := "") -> void:
	username = p_username
	text = p_text
