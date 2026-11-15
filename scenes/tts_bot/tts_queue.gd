class_name TTSQueue
extends Node

signal message_started(message: TTSMessage)
signal message_finished(message: TTSMessage, skipped: bool)
signal paused_changed(paused: bool)
signal changed ## Current, pending or history changed.
signal empty ## Nothing current, pending, or waiting in the gap.

@export var speaker: PhononSpeaker
@export_range(0.05, 10.0, 0.05, "suffix:s") var gap_time := 0.6
@export var max_pending := 100
@export var max_history := 10

var _current: TTSMessage
var _pending: Array[TTSMessage] = []
var _history: Array[TTSMessage] = []  # most recent first
var _paused := false
var _gap_timer := Timer.new()


func _ready() -> void:
	_gap_timer.one_shot = true
	_gap_timer.timeout.connect(_on_gap_timeout)
	add_child(_gap_timer)
	
	speaker.loaded.connect(_advance)
	speaker.finished.connect(_finish.bind(false))
	speaker.error.connect(func(_msg: String) -> void: _finish(false))  # don't hang on failure
	speaker.load_model()


## Returns false if rejected (blank text or queue full).
func enqueue(message: TTSMessage) -> bool:
	if message.text.strip_edges().is_empty() or _pending.size() >= max_pending:
		return false
	_pending.append(message)
	changed.emit()
	_advance()
	return true


## Pausing lets the current message finish, then holds the queue.
func set_paused(value: bool) -> void:
	if _paused == value:
		return
	_paused = value
	paused_changed.emit(value)
	_advance()


func is_paused() -> bool:
	return _paused


## Cuts off the current message, or discards the next pending one if idle.
func skip() -> void:
	if _current:
		speaker.stop()  # stop() doesn't emit finished
		_finish(true)
	else:
		remove_pending(0)


func clear() -> void:
	if _pending.is_empty():
		return
	_pending.clear()
	_after_removal()


func remove_pending(index: int) -> void:
	if index < 0 or index >= _pending.size():
		return
	_pending.remove_at(index)
	_after_removal()


func get_current() -> TTSMessage:
	return _current


## Next-to-read first. Returns a copy; limit < 0 = all.
func get_pending(limit := -1) -> Array[TTSMessage]:
	return _pending.slice(0, limit if limit >= 0 else _pending.size())


## Most recent first. Returns a copy; limit < 0 = all.
func get_history(limit := -1) -> Array[TTSMessage]:
	return _history.slice(0, limit if limit >= 0 else _history.size())


func _is_idle() -> bool:
	return _current == null and _gap_timer.is_stopped()


func _advance() -> void:
	if _paused or _pending.is_empty() or not _is_idle() or not speaker.is_loaded():
		return
	var message: TTSMessage = _pending.pop_front()
	_current = message
	message_started.emit(message)
	changed.emit()
	if _current == message:  # a listener may have skipped it
		speaker.speak(message.text)


func _finish(skipped: bool) -> void:
	if _current == null:
		return
	var message := _current
	_current = null
	_history.push_front(message)
	if _history.size() > max_history:
		_history.pop_back()
	message_finished.emit(message, skipped)
	changed.emit()
	if _pending.is_empty():
		empty.emit()
	else:
		_gap_timer.start(gap_time)


func _after_removal() -> void:
	changed.emit()
	if _pending.is_empty() and _is_idle():
		empty.emit()


func _on_gap_timeout() -> void:
	if _pending.is_empty():
		empty.emit()
	else:
		_advance()
