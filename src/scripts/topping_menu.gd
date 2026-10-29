class_name ToppingMenu
extends Control

signal serve_pressed
signal trash_pressed

const DISABLED_ALPHA_VALUE = 0.3

@onready var serve: TextureButton = %Serve
@onready var trash: TextureButton = %Trash

func _on_serve_pressed() -> void:
	serve_pressed.emit()

func _on_trash_pressed() -> void:
	trash_pressed.emit()

func set_enabled(enabled: bool) -> void:
	serve.disabled = not enabled
	serve.modulate.a = 1.0 if enabled else DISABLED_ALPHA_VALUE
	
	trash.disabled = not enabled
	trash.modulate.a = 1.0 if enabled else DISABLED_ALPHA_VALUE
