@tool
class_name Lasers extends Node3D

const LASER_SCENE: PackedScene = preload("res://src/lasers/laser.tscn")

@export var number_of_lasers: int = 4:
	set(value):
		number_of_lasers = value
		_rebuild_lasers()

@export var laser_spacing: float = 1:
	set(value):
		laser_spacing = value
		_rebuild_lasers()

@export var laser_height: float = 6:
	set(value):
		laser_height = value
		_update_laser_heights()

var _lasers: Array[Laser] = []


func _ready() -> void:
	_rebuild_lasers()


func _rebuild_lasers() -> void:
	if not is_node_ready():
		return

	_clear_lasers()

	var total_span: float = (number_of_lasers - 1) * laser_spacing
	var start_z: float = -total_span / 2.0

	for i in number_of_lasers:
		var laser: Laser = LASER_SCENE.instantiate()
		add_child(laser)
		laser.position = Vector3(0, 0, start_z + i * laser_spacing)
		laser.height = laser_height
		_lasers.append(laser)


func _clear_lasers() -> void:
	for laser in _lasers:
		if is_instance_valid(laser):
			laser.queue_free()
	_lasers.clear()


func _update_laser_heights() -> void:
	if not is_node_ready():
		return

	for laser in _lasers:
		if is_instance_valid(laser):
			laser.height = laser_height
