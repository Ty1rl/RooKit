extends SpectatorStreamExporter

@export var spectator_sub_viewport: SubViewport
@export var preview: TextureRect


func _ready() -> void:
	stream_error.connect(func(msg): push_warning("Spectator stream: " + msg))
	active = true
	
	preview.texture = spectator_sub_viewport.get_texture()
