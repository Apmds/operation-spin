extends Node

const SETTINGS_PATH: String = "user://audio_settings.cfg"
const BUS_NAMES: Array[String] = ["Master", "Music", "SFX"]

var bus_indices: Dictionary = {}

func _ready() -> void:
	_setup_buses()
	_apply_saved_volumes()

func _setup_buses() -> void:
	for bus_name in BUS_NAMES:
		var existing_index: int = AudioServer.get_bus_index(bus_name)
		if existing_index != -1:
			bus_indices[bus_name] = existing_index
			continue

		AudioServer.add_bus()
		var bus_index: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, bus_name)
		if bus_name != "Master":
			AudioServer.set_bus_send(bus_index, "Master")
		bus_indices[bus_name] = bus_index

	if AudioServer.get_bus_index("Master") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(0, "Master")
		bus_indices["Master"] = 0

func _apply_saved_volumes() -> void:
	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load(SETTINGS_PATH)
	if error == OK:
		for bus_name in BUS_NAMES:
			var value: float = float(config.get_value("audio", bus_name, 0.0))
			set_bus_volume(bus_name, value)
	else:
		for bus_name in BUS_NAMES:
			set_bus_volume(bus_name, 0.0)

func set_bus_volume(bus_name: String, value: float) -> void:
	if not bus_indices.has(bus_name):
		_setup_buses()
	var bus_index: int = bus_indices[bus_name]
	AudioServer.set_bus_volume_db(bus_index, value)
	_save_bus_volume(bus_name, value)

func save_bus_volume(bus_name: String, value: float) -> void:
	set_bus_volume(bus_name, value)

func _save_bus_volume(bus_name: String, value: float) -> void:
	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load(SETTINGS_PATH)
	if error != OK:
		config = ConfigFile.new()
	config.set_value("audio", bus_name, value)
	config.save(SETTINGS_PATH)
