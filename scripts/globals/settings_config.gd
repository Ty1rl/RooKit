extends Node

const SETTINGS_PATH = "user://settings.cfg"

var master_volume: float = 1.0


func _ready() -> void:
	load_settings()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	
	save_settings()


func save_settings() -> void:
	var config = ConfigFile.new()
	
	config.set_value("audio", "master_volume", master_volume)
	
	var error = config.save(SETTINGS_PATH)
	
	if error != OK:
		push_error("Failed to save settings!")


func load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_PATH)
	
	if error == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
