class_name Drone extends CharacterBody3D

enum FlightMode {
	NORMAL,
	POSITION
}

@export var camera: CameraArm
@onready var mesh: MeshInstance3D = $Mesh

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

var max_tilt: float = deg_to_rad(15)

var fans_reversed: bool = false
var fans_on: bool = true

func reverse_fans():
	fans_reversed = !fans_reversed

func toggle_fans() -> void:
	fans_on = !fans_on

func cycle_flight_mode() -> void:
	if (mode == FlightMode.NORMAL):
		mode = FlightMode.POSITION
		
		var tilt_basis_euler = tilt_basis.get_euler()
		tilt_basis_euler.x = 0
		tilt_basis_euler.z = 0
		tilt_basis = Basis.from_euler(tilt_basis_euler)
	
	elif (mode == FlightMode.POSITION):
		mode = FlightMode.NORMAL

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
	is_boosted = Input.is_action_pressed("boost")
	
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
	
	move_and_slide()
