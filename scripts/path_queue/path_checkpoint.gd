class_name PathCheckpoint
extends Marker2D
## A stop on a PathQueue's path. Characters wait here while the CheckpointStep
## children run top to bottom.

## Emitted when a follower may leave this checkpoint.
signal follower_released(follower: PathFollower)

## Remove the character after the last step instead of letting it walk on.
## GroupCheckpoint overrides this: it despawns exactly when it has an exit_point.
@export var despawns_character := false

## Distance along the path of this checkpoint.
var offset: float


func _ready() -> void:
	assert(get_parent() is PathQueue, "PathCheckpoint must be a direct child of a PathQueue.")
	offset = (get_parent() as PathQueue).curve.get_closest_offset(position)


## Closed checkpoints don't accept arrivals, followers queue up behind them.
func is_open() -> bool:
	return true


## Distance at which the next arriving follower stops.
func stop_distance(_spacing: float) -> float:
	return offset


## Starts this checkpoint for a follower. Does not block: follower_released is
## emitted when the follower may leave.
func arrive(follower: PathFollower) -> void:
	await play_steps(self, follower.sprite)
	follower_released.emit(follower)


## Plays a single CheckpointStep, or every CheckpointStep child of any other node, in order.
func play_steps(container: Node, character: AnimatedSprite2D = null) -> void:
	if container is CheckpointStep:
		await container.play(character)
	elif container:
		for child in container.get_children():
			if child is CheckpointStep:
				await child.play(character)
