class_name SecurityCamera extends Node3D

@onready var camera_stand_mesh: MeshInstance3D = $CameraMesh/Stand
@onready var camera_camera_mesh: MeshInstance3D = $CameraMesh/Camera

func point_to(position) -> void:
	camera_camera_mesh.look_at(position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
