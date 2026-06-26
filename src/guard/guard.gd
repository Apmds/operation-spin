class_name Guard extends DangerObject

@export var roam_points: Array[Vector3]

func go_to_point(point: Vector3) -> void:
	pass

func _ready() -> void:
	super()
	
	var tween = create_tween().finished

func _physics_process(delta: float) -> void:
	pass
