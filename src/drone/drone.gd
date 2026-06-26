class_name Drone extends CharacterBody3D

enum FlightMode {
	NORMAL,
	POSITION
}

@export var camera: CameraArm
@onready var mesh: Node3D = $Mesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape3D = $Collision
@onready var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

var position_rotation_step: float = deg_to_rad(15)

var tilt_basis: Basis
var is_boosted: bool = false
var boost_multiplier = 1.5
var wind_force = 5
var vertical_acceleration = 1
var vertical_decceleration = 1
var decceleration = 0.2
var max_vertical_speed = 3
var max_velocity = 3

var mode: FlightMode = FlightMode.NORMAL

var body_direction: Basis:
	get: return body_direction
	set(value):
		body_direction = value
		mesh.rotation = body_direction.get_euler()
		collision.rotation = body_direction.get_euler()

var max_tilt: float = deg_to_rad(15)

var fans_reversed: bool = false
var fans_on: bool = true
var last_fans_on_state: bool = true
var last_boost_state: bool = false

var noise: float = 0
var noise_goal: float = 0
const NOISE_BASE: float = 5
const NOISE_NORMAL: float = 30
const NOISE_BOOST: float = 60
const NOISE_HIT_ADD: float = 20
var noise_speed: float = 2

signal boost_changed(status: bool)
signal fans_changed(status: bool)
signal mode_changed(mode: FlightMode)

@warning_ignore("unused_signal")
signal died

var starting_sound = preload("res://assets/sound_efects/starting_drone.wav")
var turn_off_sound = preload("res://assets/sound_efects/turn_off_drone.wav")
var boost_start_sound = preload("res://assets/sound_efects/boost_drone_start.wav")
var boost_off_sound = preload("res://assets/sound_efects/boost_drone_off.wav")
var slam_wall_sound = preload("res://assets/sound_efects/slam_wall.mp3")

const SLAM_COOLDOWN: float = 0.4
var _slam_cooldown_remaining: float = 0.0

func reverse_fans():
	fans_reversed = !fans_reversed

func _ready() -> void:
	audio_player.autoplay = false
	audio_player.unit_size = 10
	audio_player.max_distance = 20
	audio_player.bus = "SFX"
	add_child(audio_player)

func play_audio(stream: AudioStream) -> void:
	audio_player.stream = stream
	audio_player.play()

func toggle_fans() -> void:
	var previous_fans_on = fans_on
	fans_on = !fans_on
	fans_changed.emit(fans_on)
	if previous_fans_on != fans_on:
		if fans_on:
			play_audio(starting_sound)
		else:
			play_audio(turn_off_sound)

func cycle_flight_mode() -> void:
	if (mode == FlightMode.NORMAL):
		mode = FlightMode.POSITION
		
		var tilt_basis_euler = tilt_basis.get_euler()
		tilt_basis_euler.x = 0
		tilt_basis_euler.z = 0
		tilt_basis = Basis.from_euler(tilt_basis_euler)
	
	elif (mode == FlightMode.POSITION):
		mode = FlightMode.NORMAL
	
	mode_changed.emit(mode)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		toggle_fans()
	
	if event.is_action_pressed("switch_modes"):
		cycle_flight_mode()
	
	# Adjust rotation based on click
	if event is InputEventKey and mode == FlightMode.POSITION:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var pitch: float = input_dir.y * position_rotation_step
		var roll: float = -input_dir.x * position_rotation_step
		
		tilt_basis = tilt_basis.rotated(tilt_basis.x, pitch)
		tilt_basis = tilt_basis.rotated(tilt_basis.z, roll)

func _physics_process(delta: float) -> void:
	# Boost control
	if fans_on:
		var new_is_boosted = Input.is_action_pressed("boost")
		if new_is_boosted != is_boosted:
			boost_changed.emit(new_is_boosted)
			if new_is_boosted:
				play_audio(boost_start_sound)
			else:
				play_audio(boost_off_sound)
		is_boosted = new_is_boosted
	
	# Add wind force
	if fans_on:
		var wind_vector = body_direction.y
		
		if wind_vector.y > 0:
			wind_vector.y = 0
		if fans_reversed:
			wind_vector = -wind_vector
		var vel_add = wind_vector * wind_force * delta
		if is_boosted:
			vel_add *= boost_multiplier
		velocity += vel_add
	
	if mode == FlightMode.NORMAL:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
		var pitch: float = input_dir.y * max_tilt
		var roll: float = -input_dir.x * max_tilt
	
		if (camera):
			direction = direction.rotated(Vector3.UP, camera.get_camera_object().global_rotation.y)
			tilt_basis = Basis(Vector3.UP, camera.get_camera_object().global_rotation.y)
			
			#body_direction = Vector3(direction.z, 0, -direction.x) * 0.1
			#body_direction = Vector3(body_direction.x, camera.get_camera_object().global_rotation.y, body_direction.z)
			#rotation.y = camera.get_camera_object().global_rotation.y
		
		tilt_basis = tilt_basis.rotated(tilt_basis.x, pitch)
		tilt_basis = tilt_basis.rotated(tilt_basis.z, roll)
	
	var up_dir := Input.get_axis("move_down", "move_up")
	if up_dir:
		var toward = up_dir*max_vertical_speed
		var accel = vertical_acceleration*delta
		if is_boosted:
			accel *= boost_multiplier
			toward *= boost_multiplier
		velocity.y = move_toward(velocity.y, toward, accel)
	else:
		velocity.y = move_toward(velocity.y, 0.0, vertical_decceleration*delta)
	
	if (mode == FlightMode.NORMAL):
		body_direction = body_direction.slerp(tilt_basis, delta * 5)
	elif (mode == FlightMode.POSITION):
		body_direction = body_direction.slerp(tilt_basis, delta * 15)
	
	if velocity.length() > max_velocity:
		velocity = velocity.normalized()*max_velocity;
	
	# Small drag
	velocity.x = lerp(velocity.x, 0.0, decceleration*delta)
	velocity.z = lerp(velocity.z, 0.0, decceleration*delta)
	
	if is_on_wall() or is_on_ceiling() or is_on_floor():
		velocity *= 0.1
		velocity = get_last_slide_collision().get_normal() * 1.2
		noise += NOISE_HIT_ADD
		if _slam_cooldown_remaining <= 0.0:
			play_audio(slam_wall_sound)
			_slam_cooldown_remaining = SLAM_COOLDOWN
	
	_slam_cooldown_remaining = max(0.0, _slam_cooldown_remaining - delta)
	
	# Noise/animation things
	if fans_on:
		if is_boosted:
			noise_goal = NOISE_BOOST
			animation_player.play("spin_fast")
		else:
			noise_goal = NOISE_NORMAL
			animation_player.play("spin_normal")
	else:
		noise_goal = NOISE_BASE
		animation_player.play("default")
	noise = lerp(noise, noise_goal, noise_speed*delta)
	
	move_and_slide()
