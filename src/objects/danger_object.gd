class_name DangerObject extends Node3D

signal sense_danger(this: DangerObject)
signal danger_stopped(this: DangerObject)

# Helper for set_outline
func set_mesh_surface_next_pass_color_alpha(mesh: MeshInstance3D, surface: int, alpha: float) -> void:
	var mat: ShaderMaterial = mesh.mesh.surface_get_material(surface).next_pass
	var color: Color = mat.get_shader_parameter("color")
	color.a = alpha
	mat.set_shader_parameter("color", color)

# Override in subclasses
@warning_ignore("unused_parameter")
func set_outline(val: bool) -> void:
	pass

func _on_sense_danger(_obj) -> void:
	set_outline(true)

func _on_danger_stopped(_obj)  -> void:
	set_outline(false)

func _ready() -> void:
	set_outline(false)
	sense_danger.connect(_on_sense_danger)
	danger_stopped.connect(_on_danger_stopped)
