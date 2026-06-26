class_name SecurityCamera extends DangerObject

@onready var camera_stand_mesh: MeshInstance3D = $CameraMesh/Stand
@onready var camera_camera_mesh: MeshInstance3D = $CameraMesh/Camera
@onready var detection_area: Area3D = $DetectionArea
@onready var timer: Timer = $Timer
@onready var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

var camera_turn_sound = preload("res://assets/sound_efects/camera_turn.mp3")

var focused_object: Node3D
var focus_rotation_speed = 3
var _was_tracking: bool = false

const DETECTION_CONE_ANGLE: float = deg_to_rad(60)

func _ready() -> void:
	audio_player.bus = "SFX"
	add_child(audio_player)
	set_outline(false)

func set_outline(val: bool) -> void:
	if val:
		set_mesh_surface_next_pass_color_alpha(camera_stand_mesh, 0, 1)
		set_mesh_surface_next_pass_color_alpha(camera_camera_mesh, 0, 1)
	else:
		set_mesh_surface_next_pass_color_alpha(camera_stand_mesh, 0, 0)
		set_mesh_surface_next_pass_color_alpha(camera_camera_mesh, 0, 0)

func get_angle_to_focused() -> float:
	var to_target = (focused_object.global_position - camera_camera_mesh.global_position).normalized()
	var facing = -camera_camera_mesh.global_basis.z # Godot 3D forward is -Z
	return facing.angle_to(to_target)

func looking_at_focused() -> bool:
	return get_angle_to_focused() < DETECTION_CONE_ANGLE/2 and has_line_of_sight()

# To resume the default behavior (rotating back and forth, be stopped or smth)
func resume_default() -> void:
	focused_object = null

func senses_danger() -> bool:
	return focused_object != null and looking_at_focused()

func point_to(obj: Node3D, weight: float) -> void:
	var a = camera_camera_mesh.basis.slerp(basis_looking_at(position, obj.position), weight)
	
	camera_camera_mesh.basis = a

func basis_looking_at(base_pos: Vector3, target_pos: Vector3) -> Basis:
	return Basis.looking_at(target_pos - base_pos, Vector3.UP)

func has_line_of_sight() -> bool:
	var space_state = get_world_3d().direct_space_state
	var from = camera_camera_mesh.global_position
	var to = focused_object.global_position

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]  # don't let the camera's own body block itself
	# query.collision_mask = ...  # set this if you only want to hit "wall"-type layers

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return true  # nothing in the way

	# If the first thing the ray hits IS the focused object (or a child of it),
	# then there's nothing blocking the view
	var collider = result.collider
	return collider == focused_object or collider.is_ancestor_of(focused_object) or focused_object.is_ancestor_of(collider)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	timer.wait_time = 2
	if focused_object:
		if looking_at_focused():
			point_to(focused_object, focus_rotation_speed*delta)
			set_outline(true)
			if !_was_tracking:
				_was_tracking = true
				audio_player.stream = camera_turn_sound
				audio_player.play()
			if timer.is_stopped():
				timer.start()
				sense_danger.emit(self)
		else:
			set_outline(false)
			_was_tracking = false
			if !timer.is_stopped():
				timer.stop()
				danger_stopped.emit(self)
	else:
		set_outline(false)
		_was_tracking = false
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
