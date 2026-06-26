class_name Guard extends DangerObject

@onready var animation_player: AnimationPlayer = $citizen/AnimationPlayer
@onready var citizen_model: Node3D = $citizen

@export var roam_points: Array[Vector3]
var current_point_idx: int = 0
const WALK_SPEED: float = 2
const RUN_SPPED: float = 6

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
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	var callback: Callable = func ():
		var next_point2: Vector3 = get_next_point()
		var current_point2: Vector3 = roam_points[current_point_idx]
		var tween2: Tween = create_tween().set_ease(Tween.EASE_OUT)
		tween2.tween_property(citizen_model, "global_position", next_point2, (next_point2 - current_point2).length()/WALK_SPEED)
		
		var callback2: Callable = func ():
			current_point_idx = get_next_idx()
			roam_next_point()
		tween2.tween_callback(callback2)
		
	var next_point: Vector3 = get_next_point()
	var current_point: Vector3 = roam_points[current_point_idx]
	var direction: Vector3 = (next_point - current_point)
	direction.y = 0  # ignore vertical difference, only turn around Y axis

	if direction.length_squared() > 0.0001:
		var target_y_rotation: float = atan2(direction.x, direction.z)
		tween.tween_property(citizen_model, "rotation:y", target_y_rotation, 1)

	tween.tween_callback(callback)

func _ready() -> void:
	super()
	
	roam_next_point()
