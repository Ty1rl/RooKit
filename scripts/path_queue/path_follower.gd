class_name PathFollower
extends PathFollow2D
## A character riding a PathQueue's path.

var character: Node2D
var sprite: AnimatedSprite2D
var speed: float
var walk_animation: StringName
var distance := 0.0 # Copy of progress, so comparisons are exact.
var next_checkpoint := 0
var is_at_checkpoint := false


func _init() -> void:
	loop = false
	rotates = false


func move_to(new_distance: float) -> void:
	var previous_x := global_position.x
	distance = new_distance
	progress = new_distance
	face(global_position.x - previous_x)


func face(dx: float) -> void:
	if not is_zero_approx(dx):
		sprite.flip_h = dx < 0.0


## Walks the character off the path to a global position, at this follower's speed.
func walk_to(target: Vector2) -> void:
	face(target.x - character.global_position.x)
	sprite.play(walk_animation)
	var tween := create_tween()
	tween.tween_property(character, "global_position", target, character.global_position.distance_to(target) / speed)
	await tween.finished
