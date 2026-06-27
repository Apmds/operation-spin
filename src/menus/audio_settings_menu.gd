extends Control

const BUS_NAMES: Array[String] = ["Master", "Music", "SFX"]

@onready var toggle_button: Button = %ToggleButton
@onready var panel_container: PanelContainer = %SettingsPanel
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

func _ready() -> void:
	AudioSettings._ready()
	_setup_slider_values()
	panel_container.visible = false
	toggle_button.pressed.connect(_on_toggle_button_pressed)
	master_slider.value_changed.connect(_on_slider_value_changed.bind("Master"))
	music_slider.value_changed.connect(_on_slider_value_changed.bind("Music"))
	sfx_slider.value_changed.connect(_on_slider_value_changed.bind("SFX"))

func _setup_slider_values() -> void:
	master_slider.min_value = -80.0
	master_slider.max_value = 0.0
	master_slider.step = 1.0
	music_slider.min_value = -80.0
	music_slider.max_value = 0.0
	music_slider.step = 1.0
	sfx_slider.min_value = -80.0
	sfx_slider.max_value = 0.0
	sfx_slider.step = 1.0

	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load(AudioSettings.SETTINGS_PATH)
	var master_db: float = 0.0
	var music_db: float = 0.0
	var sfx_db: float = 0.0

	if error == OK:
		master_db = float(config.get_value("audio", "Master", 0.0))
		music_db = float(config.get_value("audio", "Music", 0.0))
		sfx_db = float(config.get_value("audio", "SFX", 0.0))

	AudioSettings.set_bus_volume("Master", master_db)
	AudioSettings.set_bus_volume("Music", music_db)
	AudioSettings.set_bus_volume("SFX", sfx_db)

	master_slider.value = master_db
	music_slider.value = music_db
	sfx_slider.value = sfx_db

func _on_toggle_button_pressed() -> void:
	panel_container.visible = not panel_container.visible

func _on_slider_value_changed(value: float, bus_name: String) -> void:
	AudioSettings.set_bus_volume(bus_name, value)
