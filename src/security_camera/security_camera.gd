class_name SecurityCamera extends Node3D

@onready var camera_stand_mesh: MeshInstance3D = $CameraMesh/Stand
@onready var camera_camera_mesh: MeshInstance3D = $CameraMesh/Camera
@onready var detection_area: Area3D = $DetectionArea

var focused_object: Node3D
var focus_rotation_speed = 3

# To resume the default behavior (rotating back and forth, be stopped or smth)
func resume_default() -> void:
	focused_object = null

func point_to(obj: Node3D, weight: float) -> void:
	var a = camera_camera_mesh.basis.slerp(basis_looking_at(position, obj.position), weight)
	
	camera_camera_mesh.basis = a
	detection_area.basis = a

func basis_looking_at(base_pos: Vector3, target_pos: Vector3) -> Basis:
	return Basis.looking_at(target_pos - base_pos, Vector3.UP)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if focused_object:
		point_to(focused_object, focus_rotation_speed*delta)

func _on_detection_area_body_entered(body: Node3D) -> void:
	focused_object = body

func _on_detection_area_body_exited(body: Node3D) -> void:
	resume_default()
