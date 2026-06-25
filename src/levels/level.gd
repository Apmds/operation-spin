class_name Level extends Node3D

var fans_off_tex = preload("res://assets/ui/fan_status_off.png")
var fans_on_tex = preload("res://assets/ui/fan_status_on.png")
var fans_boost_tex = preload("res://assets/ui/fan_status_boost.png")

var damage_indicator_tex = preload("res://assets/ui/damage_indicator.png")

@onready var UI: Control = $UI
@onready var ui_fans_status: TextureRect = %"Fans status"
@onready var ui_noise_status: TextureProgressBar = %"Noise status"
@onready var ui_mode_status: Label = $"UI/Mode status"
@onready var ui_danger_indicator_control: Control = %"Danger Indicators"

@onready var drone: Drone = $Drone

class DangerIndicator:
	var object: Node
	var indicator_in_scene: TextureRect
	var death_timer: Timer
	var danger_list_control: Control
	
	@warning_ignore("shadowed_variable")
	func _init(object: Node, indicator_in_scene: TextureRect, danger_list_control: Control):
		self.object = object
		self.indicator_in_scene = indicator_in_scene
		
		self.death_timer = Timer.new()
		self.death_timer.one_shot = true
		self.death_timer.wait_time = 1
		self.death_timer.timeout.connect(self.remove)
		
		self.danger_list_control = danger_list_control
	
	func add():
		self.danger_list_control.add_child(indicator_in_scene)
		self.danger_list_control.add_child(self.death_timer)
	
	func shadow():
		self.death_timer.start()
	
	func remove():
		self.danger_list_control.remove_child(indicator_in_scene)
		self.danger_list_control.remove_child(self.death_timer)
	
	func update():
		var percentage_done = 1- (self.death_timer.time_left / self.death_timer.wait_time)
		
		# TODO: update angle
		
		self.indicator_in_scene.modulate.a = percentage_done

var danger_indicators: Array[DangerIndicator] = []

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

func make_danger_indicator_rect() -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	
	rect.texture = damage_indicator_tex
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.position = Vector2(-float(damage_indicator_tex.get_width())/2, -100)
	rect.pivot_offset = Vector2(float(damage_indicator_tex.get_width())/2, 100)
	rect.scale = Vector2(1.5, 1.5)
	rect.size = Vector2(damage_indicator_tex.get_width(), damage_indicator_tex.get_height())
	
	return rect

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

func _on_danger_sensed(obj: DangerObject) -> void:
	var indicator: DangerIndicator = DangerIndicator.new(obj, make_danger_indicator_rect(), ui_danger_indicator_control)
	danger_indicators.append(indicator)
	
	indicator.add()

func _on_danger_stopped(obj: DangerObject) -> void:
	var find_func: Callable = func (ind: DangerIndicator) -> bool:
		return ind.object == obj
	
	var rem_pos: int = danger_indicators.find_custom(find_func)
	if rem_pos == -1: # Ignore edge case (hack but works)
		return
	
	# Start hiding the indicator
	var indicator: DangerIndicator = danger_indicators[rem_pos]
	indicator.shadow()
	
	# Remove from list when done
	var rem_indicator: Callable = func () -> void:
		danger_indicators.remove_at(rem_pos)
	indicator.death_timer.timeout.connect(rem_indicator)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fans_on = true
	boost_status = false
	noise_level = 0
	mode = Drone.FlightMode.NORMAL
	
	for child in get_children():
		if child is DangerObject:
			child.sense_danger.connect(_on_danger_sensed)
			child.danger_stopeed.connect(_on_danger_stopped)

func _physics_process(_delta: float) -> void:
	noise_level = drone.noise
	
	for indicator: DangerIndicator in danger_indicators:
		indicator.update()
