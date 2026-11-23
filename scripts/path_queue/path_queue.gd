class_name PathQueue
extends Path2D
## Feeds queued characters onto the path a few at a time. Each one
## walks forward, keeps its distance from the character ahead, and runs every
## PathCheckpoint it reaches.

signal active_queue_started
signal active_queue_emptied

## Most characters allowed on the path at once.
@export var max_followers := 12
@export var spacing := 148.0
@export var default_speed := 148.0
@export var walk_animation: StringName = &"walk"
@export var idle_animation: StringName = &"idle"

var _path_length: float
var _checkpoints: Array[PathCheckpoint] = []
var _pending: Array[QueueRequest] = []
var _active: Array[PathFollower] = [] # Front of the queue first.


class QueueRequest:
	var scene: PackedScene
	var speed: float
	var properties: Dictionary
	
	func _init(requested_scene: PackedScene, requested_speed: float, requested_properties: Dictionary) -> void:
		scene = requested_scene
		speed = requested_speed
		properties = requested_properties


func _ready() -> void:
	assert(curve and curve.get_baked_length() > 0.0, "PathQueue needs a Curve2D with a length.")
	_path_length = curve.get_baked_length()
	
	for child in get_children():
		if child is PathCheckpoint:
			_checkpoints.append(child)
			child.follower_released.connect(_on_follower_released.bind(child))
	_checkpoints.sort_custom(func(a: PathCheckpoint, b: PathCheckpoint) -> bool: return a.offset < b.offset)


## Queues a character. `properties` are set on the character before it enters the tree,
## so its _ready() sees them, e.g. enqueue(scene, 0.0, {name = "Ann", type = "Guest"}).
func enqueue(scene: PackedScene, speed := 0.0, properties := {}) -> void:
	_pending.append(QueueRequest.new(scene, speed if speed > 0.0 else default_speed, properties))


func _process(delta: float) -> void:
	var leader: PathFollower = null
	for follower in _active:
		if not follower.is_at_checkpoint:
			_advance(follower, leader, delta)
		leader = follower
	
	if not _active.is_empty():
		var front := _active[0]
		if front.distance >= _path_length and not front.is_at_checkpoint:
			_despawn(front)
	
	_spawn_next_if_room()


func _advance(follower: PathFollower, leader: PathFollower, delta: float) -> void:
	var checkpoint := _next_checkpoint(follower)
	var stop := checkpoint.stop_distance(spacing) if checkpoint else INF
	var limit := minf(_path_length, stop)
	if leader:
		limit = minf(limit, leader.distance - spacing)
	
	var previous := follower.distance
	follower.move_to(minf(previous + follower.speed * delta, limit))
	
	if checkpoint and checkpoint.is_open() and follower.distance >= stop:
		follower.next_checkpoint += 1
		_visit(follower, checkpoint)
		return
	
	var animation := walk_animation if follower.distance > previous else idle_animation
	if follower.sprite.animation != animation:
		follower.sprite.play(animation)


func _next_checkpoint(follower: PathFollower) -> PathCheckpoint:
	return _checkpoints[follower.next_checkpoint] if follower.next_checkpoint < _checkpoints.size() else null


func _visit(follower: PathFollower, checkpoint: PathCheckpoint) -> void:
	follower.is_at_checkpoint = true
	follower.sprite.play(idle_animation)
	checkpoint.arrive(follower)


func _on_follower_released(follower: PathFollower, checkpoint: PathCheckpoint) -> void:
	if follower.is_removed:
		return
	
	if checkpoint.despawns_character:
		_despawn.call_deferred(follower) # Deferred: may fire mid-iteration if the checkpoint has no steps.
	else:
		follower.is_at_checkpoint = false


func _spawn_next_if_room() -> void:
	if _pending.is_empty() or _active.size() >= max_followers:
		return
	if not _active.is_empty() and _active[-1].distance < spacing:
		return
	
	var request: QueueRequest = _pending.pop_front()
	var follower := PathFollower.new()
	add_child(follower)
	follower.character = request.scene.instantiate()
	for property in request.properties:
		assert(property in follower.character, "Character has no property '%s'." % property)
		follower.character.set(property, request.properties[property])
	follower.add_child(follower.character)
	follower.sprite = follower.character.find_child("AnimatedSprite2D", true, false)
	assert(follower.sprite, "Character scene needs an AnimatedSprite2D.")
	follower.speed = request.speed
	follower.walk_animation = walk_animation
	follower.sprite.play(walk_animation)

	if follower.character.has_signal("grabbed"):
		follower.character.grabbed.connect(_release_follower.bind(follower), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	
	var was_empty := _active.is_empty()
	_active.append(follower)
	if was_empty:
		active_queue_started.emit()


func _release_follower(follower: PathFollower) -> void:
	if follower.is_removed or not _active.has(follower):
		return
	for checkpoint in _checkpoints:
		checkpoint.forget(follower)
	follower.remove()
	_active.erase(follower)
	follower.character.reparent(get_parent(), true)
	follower.queue_free()
	
	if _active.is_empty():
		active_queue_emptied.emit()


func _despawn(follower: PathFollower) -> void:
	if not _active.has(follower):
		return
	
	_active.erase(follower)
	follower.queue_free()
	if _active.is_empty():
		active_queue_emptied.emit()
