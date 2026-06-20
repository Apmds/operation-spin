extends Node3D

@export var mouse_sens: float = 0.05

func focused() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and focused():
		rotation.y -= event.relative.x * mouse_sens
		rotation.y = wrapf(rotation.y, 0, TAU)
		
		rotation.x -= event.relative.y * mouse_sens
		rotation.x = clamp(rotation.x, -PI/2, PI/4)
	
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_released("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
