extends Control

const AUDIO_SETTINGS_SCENE: PackedScene = preload("res://src/menus/audio_settings_menu.tscn")
const LEVEL_SCENES: Dictionary = {
	1: "res://src/test_scene.tscn",
	2: "res://src/test_scene.tscn",
	3: "res://src/test_scene.tscn",
	4: "res://src/test_scene.tscn",
	5: "res://src/test_scene.tscn",
	6: "res://src/test_scene.tscn",
	7: "res://src/test_scene.tscn",
	8: "res://src/test_scene.tscn",
	9: "res://src/test_scene.tscn",
	10: "res://src/test_scene.tscn",
}

@onready var grid: GridContainer = $GridContainer
@onready var background: TextureRect = $Background

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	background.texture = preload("res://assets/models/city_rooftop_night_skybox_0.png")
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.pivot_offset = Vector2(background.size.x * 0.5, background.size.y * 0.5)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(background, "rotation_degrees", 1.2, 20.0)
	tween.tween_property(background, "rotation_degrees", -1.2, 20.0)
	_add_audio_settings_menu()
	_build_level_buttons()

func _add_audio_settings_menu() -> void:
	var settings_menu: Control = AUDIO_SETTINGS_SCENE.instantiate()
	add_child(settings_menu)
	settings_menu.set_anchors_preset(Control.PRESET_TOP_LEFT)
	settings_menu.position = Vector2(16, 16)

func _build_level_buttons() -> void:
	for child in grid.get_children():
		child.queue_free()

	var progress: Dictionary = _load_progress()
	for level_number in range(1, 11):
		var button: Button = Button.new()
		button.text = str(level_number)
		button.custom_minimum_size = Vector2(100, 100)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_level_pressed.bind(level_number))
		button.add_theme_font_size_override("font_size", 34)

		# Garantir que o texto fica sempre branco
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_color_override("font_focus_color", Color.WHITE)
		button.add_theme_color_override("font_disabled_color", Color.WHITE)

		var is_unlocked: bool = level_number == 1 or progress.get(level_number - 1, false)

		# 1. Criar o fundo base (estilo "normal")
		var bg_style := StyleBoxFlat.new()
		if not is_unlocked:
			bg_style.bg_color = Color(0.25, 0.25, 0.25, 0.95)   # bloqueado
			button.disabled = true
		elif progress.get(level_number, false):
			bg_style.bg_color = Color(0.15, 0.55, 0.25, 0.95)   # completo (verde)
		else:
			bg_style.bg_color = Color(1.0, 0.85, 0.0, 0.95)     # desbloqueado (amarelo)

		bg_style.corner_radius_top_left = 8
		bg_style.corner_radius_top_right = 8
		bg_style.corner_radius_bottom_left = 8
		bg_style.corner_radius_bottom_right = 8

		# Aplicar o estilo "normal"
		button.add_theme_stylebox_override("normal", bg_style)

		# 2. Criar estilos hover e pressed ligeiramente mais escuros
		#    (só faz sentido para botões não desabilitados, mas podemos criar na mesma
		#     – o Godot ignora‑os quando está disabled)
		if not button.disabled:
			# Hover: escurece um pouco (factor 0.1)
			var hover_style := bg_style.duplicate() as StyleBoxFlat
			hover_style.bg_color = bg_style.bg_color.darkened(0.1)
			button.add_theme_stylebox_override("hover", hover_style)

			# Pressed: escurece um pouco mais (factor 0.2)
			var pressed_style := bg_style.duplicate() as StyleBoxFlat
			pressed_style.bg_color = bg_style.bg_color.darkened(0.2)
			button.add_theme_stylebox_override("pressed", pressed_style)
		else:
			# Se estiver disabled, definimos um estilo disabled ainda mais escuro
			var disabled_style := bg_style.duplicate() as StyleBoxFlat
			disabled_style.bg_color = bg_style.bg_color.darkened(0.3)
			button.add_theme_stylebox_override("disabled", disabled_style)

		grid.add_child(button)

func _on_level_pressed(level_number: int) -> void:
	var path: String = LEVEL_SCENES.get(level_number, "")
	if path.is_empty():
		return
	SaveManager.set_selected_level(level_number)
	get_tree().change_scene_to_file(path)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menus/main_menu.tscn")

func _load_progress() -> Dictionary:
	var progress: Dictionary = {}
	for key in SaveManager.get_progress_keys():
		progress[int(key)] = SaveManager.is_level_complete(int(key))
	return progress
