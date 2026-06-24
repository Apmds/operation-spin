extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const NOISE_THRESHOLD: float = 50
var noise_speed: float = 3
var denoise_speed: float = 1
var noise: float = 0
var focused_object: Drone

func _on_detection_area_body_entered(body: Node3D) -> void:
	print("AAAAA")
	if focused_object is Drone:
		focused_object = body

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == focused_object:
		focused_object = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("beep")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if focused_object:
		noise = lerp(noise, focused_object.noise, noise_speed*delta)
	else:
		noise = lerp(noise, 0.0, denoise_speed*delta)
	
	#print(noise)
	if noise >= NOISE_THRESHOLD:
		focused_object.died.emit()
		
