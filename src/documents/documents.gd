class_name Documents extends Area3D

@onready var tooltip = $Tooltip

var player_in_range: bool = false

signal documents_grabbed

func _ready() -> void:
	tooltip.hide()

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("get_documents"):
		documents_grabbed.emit()

func _on_body_entered(_body: Node3D) -> void:
	tooltip.show()
	player_in_range = true

func _on_body_exited(_body: Node3D) -> void:
	tooltip.hide()
	player_in_range = false
