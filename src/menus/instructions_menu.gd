extends Control

@onready var background: TextureRect = $Background

@onready var drone: Node3D = %Drone
@onready var drone_animation_player: AnimationPlayer

@onready var content_text: RichTextLabel = %ContentText
@onready var last_panel_button: Button = %LastPanelButton
@onready var next_panel_button: Button = %NextPanelButton

@onready var rotate_drone_timer: Timer = %RotateTimer

var current_menu: int = 0
const NUMBER_OF_MENUS: int = 3

func start_rotating_drone():
	rotate_drone_timer.start()

func stop_rotating_drone():
	rotate_drone_timer.stop()
	drone.rotation = Vector3.ZERO

func previous_menu() -> void:
	if current_menu > 0:
		current_menu -= 1
	
	update_menu()

func next_menu() -> void:
	if current_menu < NUMBER_OF_MENUS - 1:
		current_menu += 1
	
	update_menu()

func play_normal() -> void:
	drone.get_node("Model/blur1").visible = false
	drone.get_node("Model/blur2").visible = false
	drone.get_node("Model/blur3").visible = false
	drone.get_node("Model/blur4").visible = false
	drone.get_node("Model/helice1").visible = true
	drone.get_node("Model/helice2").visible = true
	drone.get_node("Model/helice3").visible = true
	drone.get_node("Model/helice4").visible = true
	
	drone_animation_player.play("spin_normal")

func play_fast() -> void:
	drone.get_node("Model/blur1").visible = true
	drone.get_node("Model/blur2").visible = true
	drone.get_node("Model/blur3").visible = true
	drone.get_node("Model/blur4").visible = true
	drone.get_node("Model/helice1").visible = false
	drone.get_node("Model/helice2").visible = false
	drone.get_node("Model/helice3").visible = false
	drone.get_node("Model/helice4").visible = false
	
	drone_animation_player.play("spin_fast")

func _loop_normal_stop_fast() -> void:
	if current_menu != 1:
		return
	
	get_tree().create_timer(1.0).timeout.connect(func ():
		if current_menu != 1:
			return
		drone_animation_player.stop()
		
		get_tree().create_timer(1.0).timeout.connect(func ():
			if current_menu != 1:
				return
			play_fast()
			
			get_tree().create_timer(1.0).timeout.connect(func ():
				if current_menu != 1:
					return
				play_normal()
				_loop_normal_stop_fast()
			)
		)
	)

func update_menu() -> void:
	last_panel_button.disabled = false
	next_panel_button.disabled = false
	
	stop_rotating_drone()
	
	match current_menu:
		0: # Basics
			last_panel_button.disabled = true
			content_text.text = (
				"You are a drone piloted by a spy in order to steal secret documents.\n" +
				"\n" +
				"- [b]WASD[/b]: regular movement\n" +
				"- [b]E[/b]: move up\n" +
				"- [b]Q[/b]: move down\n" +
				"- [b]F[/b]: collect documents"
			)
			
			play_normal()
		1: # Boost/turn on/turn off
			content_text.text = (
				"In order to fly undetected, you can your engine on or off (you keep your altitude, because reasons).\n" +
				"You can also boost your movement, which makes you move faster, but produces a lot of noise.\n" +
				"Colliding with walls also causes noise, so be careful.\n" +
				"\n" + 
				"- [b]Space[/b]: toggle engine\n" +
				"- [b]Left shift[/b]: boost"
				
			)
			
			play_normal()
			_loop_normal_stop_fast()
			
		2: # Rotation modes
			last_panel_button.disabled = false
			content_text.text = (
				"The facility has heavy security, which forces you to weave past tight sections.\n" +
				"You can switch to position mode, where you can freely rotate the drone.\n" +
				"(tip: the drone has practically no air resistance, so momentum gets carried).\n" +
				"\n" + 
				"- [b]R[/b]: switch flight mode"
				#"" +
				#"[b]Enemies[/b]" +
				#"- Security cameras: detect movement" +
				#"- Noise sensors: detect sound" +
				#"- lasers: detect colision" +
				#"- Guard: detects sound and movement"
			)
			
			play_normal()
			start_rotating_drone()

func _ready() -> void:
	drone_animation_player = drone.get_node("AnimationPlayer")
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	background.pivot_offset = Vector2(background.size.x * 0.5, background.size.y * 0.5)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(background, "rotation_degrees", 1.2, 20.0)
	tween.tween_property(background, "rotation_degrees", -1.2, 20.0)
	
	update_menu()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/menus/main_menu.tscn")

func _on_last_panel_button_pressed() -> void:
	previous_menu()

func _on_next_panel_button_pressed() -> void:
	next_menu()

func _on_rotate_timer_timeout():
	# Rotate drone 15 deg in a random axis
	var axes := [Vector3.RIGHT, Vector3.UP, Vector3.FORWARD]
	var axis: Vector3 = axes[randi() % axes.size()]
	
	var current_basis := Basis.from_euler(drone.rotation)
	var rotated_basis := current_basis.rotated(axis, deg_to_rad(15))
	
	drone.rotation = rotated_basis.get_euler()
