class_name GroupCheckpoint
extends PathCheckpoint
## A buffer along the queue. Followers stop here with normal queue spacing until
## group_size of them are waiting or max_wait runs out, then the sequence plays
## and the buffer reopens for the followers behind.

signal _turns_finished

@export var group_size := 3
## Seconds to wait for a full group before going with whoever is here. 0 waits forever.
@export var max_wait := 0.0
## True: followers take turns in arrival order and are released as soon as their own turn ends.
## False: all followers take their turn together and are released after on_done.
@export var one_at_a_time := true
## Played while waiting. Defaults to the queue's idle animation.
@export var wait_animation: StringName
## Where each follower walks to before its turn. Setting this despawns followers afterwards.
## leave empty to play per_follower in place and let them continue along the path.
@export var exit_point: Marker2D
## Played when the group is ready.
@export var on_full: Node
## Played for every follower. Steps should animate the follower (no sprite set) when one_at_a_time is off.
@export var per_follower: Node
## Played once every follower has had its turn.
@export var on_done: Node

var _members: Array[PathFollower] = [] # In arrival order, front of the queue first.
var _timer := Timer.new()
var _running := false
var _turns_left := 0


func _ready() -> void:
	super()
	assert(group_size <= get_parent().max_followers, "The queue's max_followers must be at least group_size.")
	despawns_character = exit_point != null
	_timer.one_shot = true
	_timer.timeout.connect(_start)
	add_child(_timer)


func is_open() -> bool:
	return not _running and _members.size() < group_size


func stop_distance(spacing: float) -> float:
	return _members[-1].distance - spacing if not _members.is_empty() else offset


func arrive(follower: PathFollower) -> void:
	_members.append(follower)
	if wait_animation:
		follower.sprite.play(wait_animation)
	if _members.size() == 1 and max_wait > 0.0:
		_timer.start(max_wait)
	if _members.size() == group_size:
		_start()


func _start() -> void:
	if _running:
		return
	_running = true
	_timer.stop()
	
	await play_steps(on_full)
	
	_turns_left = _members.size()
	for member in _members.duplicate():
		if one_at_a_time:
			await _take_turn(member)
			_release(member)
		else:
			_take_turn(member)
	if _turns_left > 0:
		await _turns_finished
	
	await play_steps(on_done)
	
	for member in _members.duplicate():
		_release(member)
	_running = false


func _take_turn(member: PathFollower) -> void:
	if exit_point:
		await member.walk_to(exit_point.global_position)
	await play_steps(per_follower, member.sprite)
	_turns_left -= 1
	if _turns_left == 0:
		_turns_finished.emit()


func _release(member: PathFollower) -> void:
	_members.erase(member)
	follower_released.emit(member)
