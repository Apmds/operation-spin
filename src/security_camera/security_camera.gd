class_name SecurityCamera extends DangerObject

@onready var camera_stand_mesh: MeshInstance3D = $CameraMesh/Stand
@onready var camera_camera_mesh: MeshInstance3D = $CameraMesh/Camera
@onready var detection_area: Area3D = $DetectionArea
@onready var timer: Timer = $Timer

var focused_object: Node3D
var focus_rotation_speed = 3

const DETECTION_CONE_ANGLE: float = deg_to_rad(60)

func get_angle_to_focused() -> float:
	var to_target = (focused_object.global_position - camera_camera_mesh.global_position).normalized()
	var facing = -camera_camera_mesh.global_basis.z # Godot 3D forward is -Z
	return facing.angle_to(to_target)

func looking_at_focused() -> bool:
	return get_angle_to_focused() < DETECTION_CONE_ANGLE/2

# To resume the default behavior (rotating back and forth, be stopped or smth)
func resume_default() -> void:
	focused_object = null

func senses_danger() -> bool:
	return focused_object != null and looking_at_focused()

func point_to(obj: Node3D, weight: float) -> void:
	var a = camera_camera_mesh.basis.slerp(basis_looking_at(position, obj.position), weight)
	
	camera_camera_mesh.basis = a
	#detection_area.basis = a

func basis_looking_at(base_pos: Vector3, target_pos: Vector3) -> Basis:
	return Basis.looking_at(target_pos - base_pos, Vector3.UP)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if focused_object:
		if looking_at_focused():
			point_to(focused_object, focus_rotation_speed*delta)
			if timer.is_stopped():
				timer.start()
				sense_danger.emit(self)
	else:
		if !timer.is_stopped():
			timer.stop()
			danger_stopped.emit(self)

func _on_detection_area_body_entered(body: Node3D) -> void:
	focused_object = body

func _on_detection_area_body_exited(_body: Node3D) -> void:
	if senses_danger():
		danger_stopped.emit(self)
	
	resume_default()
	timer.stop()

func _on_timer_timeout() -> void:
	if focused_object is not Drone: # Probably will never run, but just to be good
		pass
	
	var drone: Drone = focused_object
	drone.died.emit()
	
