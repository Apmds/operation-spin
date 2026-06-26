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

@onready var camera: CameraArm = $Camera
@onready var drone: Drone = $Drone
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var soft_level_music = preload("res://assets/themes/soft_level.mp3")
var hard_level_music = preload("res://assets/themes/hard_level.mp3")

class DangerIndicator:
	var parent: Level
	var dangerous_object: Node3D
	var indicator_in_scene: TextureRect
	var death_timer: Timer
	var danger_list_control: Control
	
	@warning_ignore("shadowed_variable")
	func _init(dangerous_object: Node3D, indicator_in_scene: TextureRect, parent: Level):
		self.dangerous_object = dangerous_object
		self.parent = parent
		self.indicator_in_scene = indicator_in_scene
		
		self.death_timer = Timer.new()
		self.death_timer.one_shot = true
		self.death_timer.wait_time = 0.3
		self.death_timer.timeout.connect(self.remove)
		
		self.danger_list_control = parent.ui_danger_indicator_control
	
	func add():
		self.danger_list_control.add_child(indicator_in_scene)
		self.danger_list_control.add_child(self.death_timer)
		self.update()
	
	func shadow():
		if self.death_timer.is_inside_tree():
			self.death_timer.start()
	
	func remove():
		self.danger_list_control.remove_child(indicator_in_scene)
		self.danger_list_control.remove_child(self.death_timer)
	
	func update():
		var alpha: float
		if self.death_timer.is_stopped():
			alpha = 1
		else:
			alpha = (self.death_timer.time_left / self.death_timer.wait_time)
		
		var cam: Node3D = parent.camera.get_camera_object()
		
		# Project drone->danger direction onto the XZ plane, as a 2D vector
		var to_danger: Vector2 = Vector2(
			dangerous_object.global_position.x - parent.drone.global_position.x,
			dangerous_object.global_position.z - parent.drone.global_position.z
		)
		
		# More robust: handles any pitch, including straight down/up, without flipping
		var screen_up_3d: Vector3 = cam.global_basis.y
		var forward_3d: Vector3 = -cam.global_basis.z

		# Pick whichever projects more strongly onto the horizontal plane —
		# that's the one that's numerically stable for this pitch.
		var screen_up: Vector2
		if Vector2(forward_3d.x, forward_3d.z).length() > 0.05:
			screen_up = Vector2(forward_3d.x, forward_3d.z).normalized()
		else:
			screen_up = Vector2(screen_up_3d.x, screen_up_3d.z).normalized()

		var angle = screen_up.angle_to(to_danger)
		
		indicator_in_scene.rotation = angle
		
		self.indicator_in_scene.modulate.a = alpha

var danger_indicators: Array[DangerIndicator] = []

# This is NOT good but I don't want to waste time
const noise_levels: Array[int] = [0, 9, 16, 23, 30, 37, 44, 50, 57, 64, 70, 77, 84, 90, 100]

var noise_level: float = 0:
	get: return noise_level
	set(value): 
		noise_level = value
		ui_noise_status.value = noise_levels[noise_levels.bsearch(noise_level)-1]

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
	SaveManager.set_last_result("defeat")
	get_tree().change_scene_to_file("res://src/menus/end_menu.tscn")

func _on_documents_grabbed() -> void:
	SaveManager.set_last_result("victory")
	SaveManager.set_level_complete(SaveManager.get_selected_level(), true)
	get_tree().change_scene_to_file("res://src/menus/end_menu.tscn")

func _on_danger_sensed(obj: DangerObject) -> void:
	var indicator: DangerIndicator = DangerIndicator.new(obj, make_danger_indicator_rect(), self)
	danger_indicators.append(indicator)
	
	indicator.add()

func _on_danger_stopped(obj: DangerObject) -> void:
	var find_func: Callable = func (ind: DangerIndicator) -> bool:
		return ind.dangerous_object == obj
	
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
	MenuMusic.stop_menu_music()
	fans_on = true
	boost_status = false
	noise_level = 0
	mode = Drone.FlightMode.NORMAL
	
	music_player.bus = "Music"
	add_child(music_player)
	var level_number: int = SaveManager.get_selected_level()
	music_player.stream = soft_level_music if level_number <= 5 else hard_level_music
	music_player.volume_db = -10
	music_player.play()
	
	for child in get_children():
		if child is DangerObject:
			child.sense_danger.connect(_on_danger_sensed)
			child.danger_stopped.connect(_on_danger_stopped)

func _physics_process(_delta: float) -> void:
	noise_level = drone.noise
	
	for indicator: DangerIndicator in danger_indicators:
		indicator.update()
