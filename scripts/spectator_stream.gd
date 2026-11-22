extends SpectatorStreamExporter

@export var spectator_sub_viewport: SubViewport


func _ready() -> void:
	stream_error.connect(func(msg): push_warning("Spectator stream: " + msg))
	active = true
