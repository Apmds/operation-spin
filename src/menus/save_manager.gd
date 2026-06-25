extends Node

const SAVE_PATH := "user://save_data.cfg"

var _config := ConfigFile.new()

func _ready() -> void:
	_load()

func _load() -> void:
	var err := _config.load(SAVE_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_error("Failed to load save data: %s" % err)

func save() -> void:
	var err := _config.save(SAVE_PATH)
	if err != OK:
		push_error("Failed to save data: %s" % err)

func set_level_complete(level_number: int, completed: bool) -> void:
	_config.set_value("progress", str(level_number), completed)
	save()

func is_level_complete(level_number: int) -> bool:
	if not _config.has_section("progress"):
		return false
	return _config.get_value("progress", str(level_number), false)

func get_progress_keys() -> Array:
	if not _config.has_section("progress"):
		return []
	return _config.get_section_keys("progress")

func set_selected_level(level_number: int) -> void:
	_config.set_value("meta", "selected_level", level_number)
	save()

func get_selected_level() -> int:
	return _config.get_value("meta", "selected_level", 1)

func set_last_result(result: String) -> void:
	_config.set_value("meta", "last_result", result)
	save()

func get_last_result() -> String:
	return _config.get_value("meta", "last_result", "defeat")
