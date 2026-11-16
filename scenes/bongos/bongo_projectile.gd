extends RigidBody2D


func _ready() -> void:
	apply_impulse(Vector2(randf_range(-1000, 1000), -2000))

func _on_timer_timeout() -> void:
	queue_free()
