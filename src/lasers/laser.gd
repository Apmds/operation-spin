@tool
class_name Laser extends DangerObject

@export var height: float = 4.0:
	set(value):
		height = value
		_update_laser()

@onready var collision: CollisionShape3D = $Collision
@onready var laser_mesh: MeshInstance3D = $LaserBase/LaserMesh
@onready var laser_top_base: Node3D = $LaserBase/LaserMesh/LaserBase

@onready var timer: Timer = $DeathTimer

var drone: Drone

func _ready() -> void:
	super()
	_update_laser()


func _update_laser() -> void:
	if not is_node_ready():
		return

	if laser_mesh.mesh is CylinderMesh:
		laser_mesh.mesh.height = height
	laser_mesh.position.y = height / 2.0

	if collision.shape is BoxShape3D:
		var box_shape: BoxShape3D = collision.shape
		var size = box_shape.size
		size.y = height
		box_shape.size = size
	collision.position.y = height / 2.0

	laser_top_base.position.y = height / 2.0 + 0.07


func _on_body_entered(body: Node3D) -> void:
	# TODO: play alarm sound
	if body is Drone:
		drone = body
		timer.start()

func _on_death_timer_timeout() -> void:
	drone.died.emit()
