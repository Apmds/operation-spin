class_name Level extends Node3D

@onready var UI: Control = $UI
@onready var ui_boost_status: Label = $"UI/Boost status"
@onready var ui_fans_status: Label = $"UI/Fans status"
@onready var ui_noise_status: Label = $"UI/Noise status"
@onready var ui_mode_status: Label = $"UI/Mode status"

@onready var drone: Drone = $Drone

var noise_level: int = 0:
	get: return noise_level
	set(value): 
		noise_level = value
		ui_noise_status.text = "Noise: %d" % value

var boost_status: bool = false:
	get: return boost_status
	set(value): 
		boost_status = value
		ui_boost_status.text = "Boost: %s" % ("on" if value else "off")

var fans_on: bool = false:
	get: return fans_on
	set(value): 
		fans_on = value
		ui_fans_status.text = "Fans: %s" % ("on" if value else "off")

var mode: Drone.FlightMode = Drone.FlightMode.NORMAL:
	get: return mode
	set(value): 
		mode = value
		ui_mode_status.text = "Mode: %s" % Drone.FlightMode.find_key(value)

func _on_drone_boost_changed(status: bool) -> void:
	boost_status = status

func _on_drone_fans_changed(status: bool) -> void:
	fans_on = status

func _on_drone_mode_changed(new_mode: Drone.FlightMode) -> void:
	mode = new_mode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fans_on = true
	boost_status = false
	noise_level = 0
	mode = Drone.FlightMode.NORMAL

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
