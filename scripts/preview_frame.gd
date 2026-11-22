extends Control
## Scales the SubViewportContainer to fit without effecting the SubViewport size.
## Needed to maintain resolution of the SpectatorStreamExporter.

@export var preview_viewport_container: SubViewportContainer
@export var preview_viewport: SubViewport

func _ready() -> void:
	resized.connect(_fit)
	_fit()

func _fit() -> void:
	var vp := Vector2(preview_viewport.size)
	var s := minf(size.x / vp.x, size.y / vp.y)
	preview_viewport_container.size = vp
	preview_viewport_container.scale = Vector2(s, s)
	preview_viewport_container.position = (size - vp * s) * 0.5
