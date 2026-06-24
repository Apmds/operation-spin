class_name Level extends Node3D

var fans_off_tex = preload("res://assets/ui/fan_status_off.png")
var fans_on_tex = preload("res://assets/ui/fan_status_on.png")
var fans_boost_tex = preload("res://assets/ui/fan_status_boost.png")

@onready var UI: Control = $UI
@onready var ui_fans_status: TextureRect = %"Fans status"
@onready var ui_noise_status: TextureProgressBar = %"Noise status"
@onready var ui_mode_status: Label = $"UI/Mode status"

@onready var drone: Drone = $Drone

# This is NOT good but I don't want to waste time
const noise_levels: Array[int] = [0, 9, 16, 23, 30, 37, 44, 50, 57, 64, 70, 77, 84, 90, 100]

var noise_level: float = 0:
	get: return noise_level
	set(value): 
		noise_level = value
		ui_noise_status.value = noise_levels[noise_levels.bsearch(noise_level)]

var boost_status: bool = false:
	get: return boost_status
	set(value): 
		boost_status = value
		update_fans_status()

var fans_on: bool = false:
	get: return fans_on
	set(value): 
		fans_on = value
		update_fans_status()

var mode: Drone.FlightMode = Drone.FlightMode.NORMAL:
	get: return mode
	set(value): 
		mode = value
		ui_mode_status.text = "Mode: %s" % Drone.FlightMode.find_key(value)

func update_fans_status() -> void:
	if not fans_on:
		ui_fans_status.texture = fans_off_tex
		return
	
	if boost_status:
		ui_fans_status.texture = fans_boost_tex
	else:
		ui_fans_status.texture = fans_on_tex

func _on_drone_boost_changed(status: bool) -> void:
	boost_status = status

func _on_drone_fans_changed(status: bool) -> void:
	fans_on = status

func _on_drone_mode_changed(new_mode: Drone.FlightMode) -> void:
	mode = new_mode

func _on_drone_died() -> void:
	get_tree().change_scene_to_file("res://src/menus/end_menu.tscn")

func _on_documents_grabbed() -> void:
	get_tree().change_scene_to_file("res://src/menus/end_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fans_on = true
	boost_status = false
	noise_level = 0
	mode = Drone.FlightMode.NORMAL

func _physics_process(delta: float) -> void:
	noise_level = drone.noise
