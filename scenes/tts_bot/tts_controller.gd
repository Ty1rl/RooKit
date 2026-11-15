extends Control

@export var queue: TTSQueue
@export var upcoming_count := 1
@export var history_count := 1

@onready var pause_button: Button = %PauseButton
@onready var history_label: Label = %HistoryLabel
@onready var pending_label: Label = %PendingLabel


func _ready() -> void:
	queue.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	pending_label.text = "Up next\n" + _format(queue.get_pending(upcoming_count))
	history_label.text = "History\n" + _format(queue.get_history(history_count))


func _format(messages: Array) -> String:
	var lines := PackedStringArray()
	for m: TTSMessage in messages:
		lines.append("%s: %s" % [m.username, m.text])
	return "-" if lines.is_empty() else "\n".join(lines)


func _on_stop_button_pressed() -> void:
	queue.skip()
	
	pause_button.button_pressed = true


func _on_pause_button_toggled(toggled_on: bool) -> void:
	queue.set_paused(toggled_on)
	
	if toggled_on:
		pause_button.text = "Play"
	else:
		pause_button.text = "Pause"


func _on_skip_button_pressed() -> void:
	queue.skip()
