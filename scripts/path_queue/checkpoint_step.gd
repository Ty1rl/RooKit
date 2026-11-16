class_name CheckpointStep
extends Node
## One animation in a checkpoint's sequence. Add as a child of the node that holds the sequence.

## Sprite to animate. Leave empty to animate the character that reached the checkpoint.
@export var sprite: AnimatedSprite2D
@export var animation: StringName
## Hold the sequence until this animation finishes. Must not be a looping animation.
@export var wait := true


func play(character: AnimatedSprite2D) -> void:
	var target := sprite if sprite else character
	assert(target, "This step has no sprite and no character to fall back on.")
	assert(target.sprite_frames.has_animation(animation), "Missing animation '%s' on %s." % [animation, target.name])
	target.stop() # Restart even if this animation is already playing.
	target.play(animation)
	if wait:
		assert(not target.sprite_frames.get_animation_loop(animation), "Cannot wait for looping animation '%s'." % animation)
		await target.animation_finished
