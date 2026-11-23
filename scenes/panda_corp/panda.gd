class_name Panda
extends RigidBody2D

signal grabbed

@export var run_force := 1500.0
@export var grabbed_gravity_scale := 3.0
@export var mouse_smoothing := 30.0
@export var max_throw_force := 1500.0
@export var min_throw_force := 60.0
@export var upright_force := 8.0
@export var upright_smoothing := 8.0

@onready var ground_ray: RayCast2D = $GroundRay
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var user_label: RichTextLabel = $UserLabel
@onready var _sprite_effect := SpriteFrameEffect.new()

enum States {FOLLOWING, GRABBED, FREE}

var state := States.FOLLOWING
var username := ""
var size := 1.0
var run_direction := 1

var _grab_offset := Vector2.ZERO # Body center relative to the grab point, unrotated.
var _last_mouse := Vector2.ZERO
var _mouse_velocity := Vector2.ZERO


func _ready() -> void:
	user_label.install_effect(_sprite_effect)
	user_label.text = _sprite_effect.prepare_message("[b]" + username + "[/b]", user_label)
	
	# Rigidbodies lose their own scale when unfrozen, so scale the children instead.
	var factor := scale * size
	scale = Vector2.ONE
	for child in get_children():
		if child is Node2D or child is Control:
			child.scale *= factor
			child.position *= factor
	
	animated_sprite.play("idle")


func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	match state:
		States.GRABBED:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				_hold_at_mouse(physics_state)
			else:
				_release(physics_state)
		States.FREE:
			_walk_upright(physics_state)


func _hold_at_mouse(physics_state: PhysicsDirectBodyState2D) -> void:
	var step := physics_state.step
	var mouse := get_global_mouse_position()
	
	var velocity := _mouse_velocity.lerp((mouse - _last_mouse) / step, 1.0 - exp(-mouse_smoothing * step))
	var pivot_accel := (velocity - _mouse_velocity) / step
	_mouse_velocity = velocity
	_last_mouse = mouse
	
	# Pendulum on the pinned grab point: gravity minus the pivot's acceleration.
	var rot := physics_state.transform.get_rotation()
	var offset := _grab_offset.rotated(rot)
	var pivot_inertia := 1.0 / physics_state.inverse_inertia + mass * offset.length_squared()
	var torque := offset.cross(mass * (physics_state.total_gravity * grabbed_gravity_scale - pivot_accel))
	var spin := physics_state.angular_velocity + torque / pivot_inertia * step
	
	# Velocities that land the grab point on the mouse this step.
	physics_state.angular_velocity = spin
	physics_state.linear_velocity = (mouse + _grab_offset.rotated(rot + spin * step) - physics_state.transform.origin) / step


func _release(physics_state: PhysicsDirectBodyState2D) -> void:
	state = States.FREE
	
	var offset := _grab_offset.rotated(physics_state.transform.get_rotation())
	var swing := Vector2(-offset.y, offset.x) * physics_state.angular_velocity
	physics_state.linear_velocity = (_mouse_velocity + swing).limit_length(max_throw_force)
	
	var thrown_x := physics_state.linear_velocity.x
	run_direction = int(signf(thrown_x)) if absf(thrown_x) > min_throw_force else [-1, 1].pick_random()
	animated_sprite.play("walk")
	animated_sprite.flip_h = run_direction < 0


func _walk_upright(physics_state: PhysicsDirectBodyState2D) -> void:
	if ground_ray.is_colliding():
		physics_state.apply_central_force(Vector2(run_direction * run_force, 0))
	
	var target := angle_difference(physics_state.transform.get_rotation(), 0.0) * upright_force
	physics_state.angular_velocity = lerpf(physics_state.angular_velocity, target, 1.0 - exp(-upright_smoothing * physics_state.step))


func _grab() -> void:
	state = States.GRABBED
	user_label.visible = true
	collision_shape.disabled = false
	freeze = false
	lock_rotation = false
	animated_sprite.play("idle")
	
	_last_mouse = get_global_mouse_position()
	_grab_offset = (global_position - _last_mouse).rotated(-rotation)
	_mouse_velocity = Vector2.ZERO
	grabbed.emit()


func _on_animated_sprite_2d_animation_changed() -> void:
	if animated_sprite.animation == "enter":
		user_label.visible = false


func _on_grab_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_grab()


func _on_screen_exited() -> void:
	queue_free()
