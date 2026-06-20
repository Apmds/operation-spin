class_name Drone extends CharacterBody3D

@export var camera: CameraArm
@onready var mesh: MeshInstance3D = $Mesh

var body_direction: Vector3 = Vector3.UP:
	get: return body_direction
	set(value):
		print(value)
		body_direction = value
		mesh.rotation = body_direction

var max_tilt: float = deg_to_rad(15)

var wind_direction: Vector3 = Vector3.UP
var fans_on: bool = true

const SPEED = 5.0

func reverse_fans():
	wind_direction = wind_direction.rotated(Vector3.FORWARD, PI)

func toggle_fans() -> void:
	fans_on = !fans_on

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		reverse_fans()

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#print("v1")
	#print(velocity)
	
	# Add wind force
	if fans_on:
		var grav_strength: float = get_gravity().length()
		
		var wind_vector = body_direction
		
		velocity += wind_vector * grav_strength * delta
	
	#print("v2")
	#print(velocity)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var pitch = input_dir.y * max_tilt
	var roll = -input_dir.x * max_tilt
	var tilt_basis: Basis
	
	if (camera):
		direction = direction.rotated(Vector3.UP, camera.get_camera_object().global_rotation.y)
		tilt_basis = Basis(Vector3.UP, camera.get_camera_object().global_rotation.y)
		
		#body_direction = Vector3(direction.z, 0, -direction.x) * 0.1
		#body_direction = Vector3(body_direction.x, camera.get_camera_object().global_rotation.y, body_direction.z)
		#rotation.y = camera.get_camera_object().global_rotation.y
	
	tilt_basis = tilt_basis.rotated(tilt_basis.x, pitch)
	tilt_basis = tilt_basis.rotated(tilt_basis.z, roll)
	body_direction = body_direction.slerp(tilt_basis.get_euler(), delta * 5)
	
	
	#if direction:
	#	velocity.x = direction.x * SPEED
	#	velocity.z = direction.z * SPEED
	#else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)
	#	velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
