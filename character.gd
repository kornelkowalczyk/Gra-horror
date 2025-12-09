extends CharacterBody3D

# Movement Parameters
@export var speed = 2.0
@export var crouch_speed = 1
@export var sprint_speed = 2.75
@export var accel = 18.0
@export var jump = 4.6
@export var crouch_height = 0.5
@export var crouch_transition = 10.0
@export var sensitivity = 0.2
@export var min_angle = -80
@export var max_angle = 90

# Head Movement
@export var head_bob_amplitude := 0.01
@export var head_bob_frequency := 2
@export var head_tilt_amount := 0.8
@export var tilt_speed := 8.0

# Sprint System
@export var max_sprint_duration := 3.8

@onready var head = $head
@onready var camera = $head/SwayPivot/Camera3D
@onready var collision_shape = $CollisionShape3D
@onready var stamina_bar = $TextureProgressBar
@onready var sway_pivot = $head/SwayPivot

@export var air_accel = 6.0
var effective_accel = accel if is_on_floor() else air_accel

var walking = false
var sprinting = false
var crouching = false
var sliding = false

var slide_timer = 0.0
var slide_timer_max = 1.2
var slide_vector = Vector3.ZERO
var slide_speed = 12.0

var look_rot: Vector2
var stand_height: float
var stand_head_height: float
var last_vertical_velocity = 0.0
var head_bob_timer := 0.0
var current_sprint_time := max_sprint_duration

var has_key = false
var can_move := true


@onready var walking_sound = $walking_sound
@onready var sprinting_sound = $sprinting_sound

# New sway variables
var sway_timer := 0.0

@export var walk_sway_amplitude := 0.7
@export var walk_sway_frequency := 1

@export var sprint_sway_amplitude := 1.0
@export var sprint_sway_frequency := 2

@export var tilt_return_speed := 6.0

@export var normal_fov := 75.0
@export var sprint_fov := 100.0
@export var fov_transition_speed := 15.0

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _ready():
	add_to_group("player")
	stand_height = collision_shape.shape.height
	stand_head_height = collision_shape.shape.height
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not can_move:
		return
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var is_moving = direction.length() > 0
	var on_ground = is_on_floor()
	var want_sprint = Input.is_action_pressed("sprint") and is_moving
	var can_sprint = current_sprint_time > 0

	if want_sprint and can_sprint:
		if on_ground and not sprinting:
			sprinting = true
		if sprinting:
			current_sprint_time = max(current_sprint_time - delta, 0)
	else:
		sprinting = false

	if current_sprint_time <= 0:
		sprinting = false

	if not sprinting and on_ground and current_sprint_time < max_sprint_duration:
		current_sprint_time = min(current_sprint_time + delta, max_sprint_duration)

	if is_moving and on_ground and not get_node("../Sejf/VaultMenu").visible:
		if sprinting:
			if not sprinting_sound.is_playing():
				walking_sound.stop()
				sprinting_sound.play()
		else:
			if not walking_sound.is_playing():
				sprinting_sound.stop()
				walking_sound.play()
	else:
		if walking_sound.is_playing():
			walking_sound.stop()
		if sprinting_sound.is_playing():
			sprinting_sound.stop()

	stamina_bar.value = (current_sprint_time / max_sprint_duration) * 100

	var want_crouch = Input.is_action_pressed("crouch")
	if on_ground and sprinting and want_crouch and not sliding:
		sliding = true
		slide_timer = slide_timer_max
		slide_vector = velocity.normalized()
		crouching = true

	if not on_ground:
		sliding = false

	var move_speed = speed
	if sliding:
		move_speed = slide_speed
		direction = slide_vector
	elif sprinting and is_on_floor():
		move_speed = lerp(move_speed, sprint_speed, 2.5)
	elif not sprinting and not crouching:
		move_speed = speed
	elif crouching:
		move_speed = crouch_speed

	if not on_ground:
		velocity.y += get_gravity().y * delta * 1.3
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump
		sliding = false
	if not get_node("../Sejf/VaultMenu").visible:
		if sliding:
			velocity.x = move_toward(velocity.x, slide_vector.x * slide_speed, accel * delta * 0.5)
			velocity.z = move_toward(velocity.z, slide_vector.z * slide_speed, accel * delta * 0.5)
			velocity.x *= 0.96
			velocity.z *= 0.96
		elif direction:
			effective_accel = accel if on_ground else air_accel
			velocity.x = lerp(velocity.x, direction.x * move_speed, effective_accel * delta)
			velocity.z = lerp(velocity.z, direction.z * move_speed, effective_accel * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, effective_accel * 2 * delta)
			velocity.z = lerp(velocity.z, 0.0, effective_accel * 2 * delta)

		if sliding:
			slide_timer -= delta
			if slide_timer <= 0.0 or is_zero_approx(velocity.length()):
				sliding = false
				crouching = Input.is_action_pressed("crouch")
		if not get_node("../Sejf/VaultMenu").visible:
			move_speed = 0
		update_crouch(delta, want_crouch)
		apply_head_movement(delta)
		handle_head_sway(delta, is_moving, on_ground)
		move_and_slide()

		var plat_rot = get_platform_angular_velocity()
		look_rot.y += rad_to_deg(plat_rot.y * delta)
		head.rotation_degrees.x = look_rot.x
		rotation_degrees.y = look_rot.y

func update_crouch(delta: float, want_crouch: bool):
	var target_height: float
	var target_head_height: float

	if sliding:
		target_height = crouch_height * 0.6
		target_head_height = stand_head_height * 0.6
	elif want_crouch:
		target_height = crouch_height
		target_head_height = stand_head_height * (crouch_height / stand_height)
		crouching = true
	else:
		target_height = stand_height
		target_head_height = stand_head_height
		crouching = false

	collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, crouch_transition * delta)
	head.position.y = lerp(head.position.y, target_head_height, crouch_transition * delta)
	collision_shape.position.y = collision_shape.shape.height * 0.5

func apply_head_movement(delta):
	var is_moving = is_on_floor() and (velocity.x != 0.0 or velocity.z != 0.0) and not sliding and not get_node("../Sejf/VaultMenu").visible
	var current_amplitude = head_bob_amplitude
	var current_frequency = head_bob_frequency

	if sprinting:
		current_amplitude *= 2.2
		current_frequency *= 1
	elif crouching:
		current_amplitude *= 0.5
		current_frequency *= 0.3

	head_bob_timer += delta * current_frequency

	if is_moving:
		var vertical_bob = sin(head_bob_timer * PI * 2) * current_amplitude
		#head.position.y = lerp(head.position.y, stand_head_height + vertical_bob, delta * 10)
	else:
		# Subtle breathing bob when idle
		var idle_amplitude = current_amplitude * 0.3
		var idle_frequency = current_frequency * 0.5
		var idle_bob = sin(head_bob_timer * PI * 2 * idle_frequency) * idle_amplitude
		#head.position.y = lerp(head.position.y, stand_head_height + idle_bob, delta * 5)

func handle_head_sway(delta: float, is_moving: bool, on_ground: bool) -> void:
	var target_fov = sprint_fov if sprinting else normal_fov
	camera.fov = lerp(camera.fov, target_fov, delta * fov_transition_speed)

	if is_moving and on_ground and not sliding:
		sway_timer += delta
		var amplitude := walk_sway_amplitude
		var frequency := walk_sway_frequency
		if sprinting:
			amplitude = sprint_sway_amplitude
			frequency = sprint_sway_frequency

		var t = sway_timer * frequency * TAU

		var y_sway = amplitude * sin(t)
		var x_sway = amplitude * sin(t) * cos(t)
		var z_sway = sin(t) * amplitude * 2

		sway_pivot.rotation_degrees = Vector3(x_sway, y_sway, z_sway)
	else:
		# Don't reset timer, just lerp back rotation for smooth stop
		sway_pivot.rotation_degrees = sway_pivot.rotation_degrees.lerp(Vector3.ZERO, delta * tilt_return_speed)

func _input(event):
	if not can_move:
		return
	if not get_node("../Sejf/VaultMenu").visible:
		if event is InputEventMouseMotion:
			look_rot.y -= (event.relative.x * sensitivity)
			look_rot.x -= (event.relative.y * sensitivity)
			look_rot.x = clamp(look_rot.x, min_angle, max_angle)
