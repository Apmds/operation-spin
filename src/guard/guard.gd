class_name Guard extends DangerObject

var whistle_sound: AudioStreamMP3 = preload("res://assets/sound_efects/guard_whistle.mp3")
var hey_sound: AudioStreamMP3 = preload("res://assets/sound_efects/guard_surprised.mp3")

@onready var animation_player: AnimationPlayer = $citizen/AnimationPlayer
@onready var citizen_model: Node3D = $citizen
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

# Roaming vars
@export var roam_points: Array[Vector3]
var current_point_idx: int = 0
const WALK_SPEED: float = 2
const RUN_SPPED: float = 6

var tween: Tween
var tween2: Tween

var focused_object: Drone
var chasing_focused: bool = false

func get_next_point() -> Vector3:
	if current_point_idx >= len(roam_points) - 1:
		return roam_points[0]
	
	return roam_points[current_point_idx + 1]

func get_next_idx() -> int:
	if current_point_idx >= len(roam_points) - 1:
		return 0
	
	return current_point_idx + 1

func roam_next_point() -> void:
	animation_player.play("walk")

	var current_pos: Vector3 = citizen_model.global_position
	var next_point: Vector3 = get_next_point()
	var direction: Vector3 = (next_point - current_pos)
	direction.y = 0  # ignore vertical difference, only turn around Y axis

	tween = create_tween().set_ease(Tween.EASE_OUT)

	if direction.length_squared() > 0.0001:
		var target_y_rotation: float = atan2(direction.x, direction.z)
		tween.tween_property(citizen_model, "rotation:y", target_y_rotation, 1)

	var callback: Callable = func ():
		var current_pos2: Vector3 = citizen_model.global_position
		var next_point2: Vector3 = get_next_point()
		var distance: float = (next_point2 - current_pos2).length()

		tween2 = create_tween().set_ease(Tween.EASE_OUT)
		tween2.tween_property(citizen_model, "global_position", next_point2, distance / WALK_SPEED)

		var callback2: Callable = func ():
			current_point_idx = get_next_idx()
			roam_next_point()
		tween2.tween_callback(callback2)

	tween.tween_callback(callback)

func play_whistle() -> void:
	audio_player.stream = whistle_sound
	audio_player.set("parameters/looping", true)
	audio_player.play()

func play_hey() -> void:
	audio_player.stream = hey_sound
	audio_player.set("parameters/looping", false)
	audio_player.play()

func resume_default() -> void:
	focused_object = null
	play_whistle()
	roam_next_point()

func run_to_focused() -> void:
	if tween:
		tween.stop()
	if tween2:
		tween2.stop()
	
	chasing_focused = true
	animation_player.play("fast_run")

func _ready() -> void:
	super()
	
	play_whistle()
	roam_next_point()

func _physics_process(delta: float) -> void:
	if not chasing_focused or focused_object == null:
		return

	# Face the focused_object
	var direction: Vector3 = focused_object.global_position - citizen_model.global_position
	direction.y = 0  # ignore vertical difference, only turn around Y axis

	if direction.length_squared() > 0.0001:
		var target_y_rotation: float = atan2(direction.x, direction.z)
		citizen_model.rotation.y = target_y_rotation

		# Run to focused_object at RUN_SPPED
		var move_direction: Vector3 = direction.normalized()
		citizen_model.global_position += move_direction * RUN_SPPED * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Drone:
		return
	
	focused_object = body
	play_hey()
	run_to_focused()

func _on_area_3d_body_exited(_body: Node3D) -> void:
	danger_stopped.emit(self)
	resume_default()

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body is not Drone:
		return
	
	body.died.emit()
