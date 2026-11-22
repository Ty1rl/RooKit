class_name TTSBot
extends Node

@export var subscription_message: TwitchEventListener
@export var queue: TTSQueue
@export var display: TTSDisplay

#var _test_messages: Array[String] = [
	#"She sells seashells by the seashore.",
	#"Peter Piper picked a peck of pickled peppers.",
	#"How much wood would a woodchuck chuck, if a woodchuck could chuck wood?",
	#"Betty Botter bought a bit of butter, but the butter Betty Botter bought was bitter."
#]


func _ready() -> void:
	if not subscription_message:
		printerr("TTSBot: subscription_message not set")
		return
	
	subscription_message.received.connect(_on_subscription_message)
	
	queue.message_started.connect(display.show_message)
	queue.message_finished.connect(_on_message_finished)


#func _process(_delta: float) -> void:
	#queue.enqueue(TTSMessage.new("System", _test_messages.pick_random()))


func _on_subscription_message(data: Dictionary) -> void:
	queue.enqueue(TTSMessage.new(data["user_name"], data["message"]["text"]))


func _on_message_finished(_message: TTSMessage, skipped: bool) -> void:
	display.hide_message(skipped)
