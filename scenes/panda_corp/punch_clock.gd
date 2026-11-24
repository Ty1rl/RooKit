class_name PunchClock
extends Node

signal clock_in(username: String, count: String)

@export var twitch_chat: TwitchChat
@export var trigger_string: String = "rooSit"

var seen_chatters: Dictionary[String, bool] = {} # user_id, filler

var count: int = 0

var _num_regex := RegEx.new()

#var _time := 0.0
#var _test_names: Array = ["123456", "12345678", "12345678910", "123456789101112", "1234567891011121314", 
							#"12345678910111213141516", "123456789101112131415161718", "1234567891011121314151617181920"]


func _ready() -> void:
	_num_regex.compile("(?<!^)(?=(\\d{3})+$)")
	twitch_chat.message_received.connect(_on_chat_message_received)


#func _process(_delta: float) -> void:
	#_time += _delta
	#if _time > 1.0:
		#_time = 0.0
		#count += 1
		#var formated_count := format_count(count)
		#clock_in.emit(_test_names.pick_random(), formated_count)


func _on_chat_message_received(chat_message: TwitchChatMessage) -> void:
	if trigger_string not in chat_message.message.text:
		return
	
	if _seen(chat_message.chatter_user_id):
		return
	
	count += 1
	
	var formated_count := format_count(count)
	var formated_username := await format_username(chat_message)
	
	clock_in.emit(formated_username, formated_count)


func format_count(value: int) -> String:
	var text := str(value)
	text = _num_regex.sub(text, ",", true)
	return "[b]" + text + "[/b]"


func format_username(chat_message: TwitchChatMessage) -> String:
	# Get all badges from the user that sends the message
	var badges_dict : Dictionary = await chat_message.get_badges(TwitchMediaLoader.instance)
	var badges : Array[SpriteFrames] = []
	badges.assign(badges_dict.values())
	
	# Start creating the message to show
	var formated_username : String = ""
	# The sprite effect needs unique ids for every sprite that it manages
	var badge_id : int = 0
	# Add all badges to the message
	for badge: SpriteFrames in badges:
		formated_username += "[sprite id='b-%s']%s[/sprite]" % [badge_id, badge.resource_path]
		badge_id += 1
	# Add the user with its color to the message
	formated_username += "[color=%s]%s[/color] " % [chat_message.get_color(), chat_message.chatter_user_name]
	return formated_username


func _seen(user_id: String) -> bool:
	if seen_chatters.has(user_id):
		return true
	
	seen_chatters[user_id] = true
	return false
