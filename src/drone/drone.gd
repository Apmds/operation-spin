class_name Drone extends CharacterBody3D

@export var camera: CameraArm
@onready var mesh: MeshInstance3D = $Mesh

var wind_force = 1.01

var body_direction: Basis:
	get: return body_direction
	set(value):
		body_direction = value
		mesh.rotation = body_direction.get_euler()

var max_tilt: float = deg_to_rad(15)

var wind_direction: Vector3 = Vector3.UP
var fans_on: bool = true

func reverse_fans():
	wind_direction = wind_direction.rotated(Vector3.FORWARD, PI)

func toggle_fans() -> void:
	fans_on = !fans_on

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		reverse_fans()

func _physics_process(delta: float) -> void:
	# Add wind force
	if fans_on:
		var wind_vector = body_direction.y
		wind_vector = Vector3(wind_vector.x, 0, wind_vector.z)
		
		velocity += wind_vector * 5 * delta

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
	body_direction = body_direction.slerp(tilt_basis, delta * 5)
	
	move_and_slide()
