extends Control

@export var tts_bot: TTSBot
@export var upcoming_count := 1
@export var history_count := 1

@onready var volume_slider: HSlider = %VolumeSlider
@onready var pause_button: Button = %PauseButton
@onready var history_label: RichTextLabel = %HistoryLabel
@onready var pending_label: RichTextLabel = %PendingLabel

var _queue: TTSQueue
var _bus_index: int


func _ready() -> void:
	if not tts_bot:
		printerr("TTSController: tts bot not set")
		return
	
	_bus_index = AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_bus_index))
	
	_queue = tts_bot.queue
	
	_queue.changed.connect(_refresh)
	_refresh()
	
	_queue.set_paused(true)


func _refresh() -> void:
	pending_label.text = "Next\n" + _format(_queue.get_pending(upcoming_count))
	history_label.text = "Previous\n" + _format(_queue.get_history(history_count))


func _format(messages: Array) -> String:
	var lines := PackedStringArray()
	for m: TTSMessage in messages:
		lines.append("%s: %s" % [m.username, m.text])
	return "-" if lines.is_empty() else "\n".join(lines)


func _on_stop_button_pressed() -> void:
	_queue.skip()
	pause_button.button_pressed = true


func _on_pause_button_toggled(toggled_on: bool) -> void:
	_queue.set_paused(toggled_on)
	
	if toggled_on:
		pause_button.text = "Play"
	else:
		pause_button.text = "Pause"


func _on_skip_button_pressed() -> void:
	_queue.skip()


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus_index, linear_to_db(value))
	SettingsConfig.set_master_volume(value)
