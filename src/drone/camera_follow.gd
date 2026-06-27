extends Camera3D

@export var followed_node: Node3D
@export var speed: float = 50

func _physics_process(delta: float) -> void:
	position = lerp(position, followed_node.position, speed*delta)
