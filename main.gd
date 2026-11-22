extends Node

@export var twitch_chat: TwitchChat


func _ready() -> void:
	var user: TwitchUser = await _setup()
	if not user:
		return
	
	print("Connected Twitch account: %s (ID: %s)" % [user.display_name, user.id])
	await _connect_chat(user)


func _setup() -> TwitchUser:
	var twitch_service := TwitchService.instance
	
	var setup_success: bool = await twitch_service.setup()
	if not setup_success:
		printerr("Failed to setup Twitch")
		return null
	
	var user: TwitchUser = await twitch_service.get_current_user()
	if not user:
		printerr("Failed to get Twitch user")
		return null
	
	return user


func _connect_chat(twitch_user: TwitchUser) -> void:
	if twitch_chat == null:
		return
	
	twitch_chat.broadcaster_user = twitch_user
	await twitch_chat.subscribe()
	
	print("Twitch chat connected.")
