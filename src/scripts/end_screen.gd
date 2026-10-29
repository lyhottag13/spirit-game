class_name EndScreen
extends Control

@onready var label: Label = %Label

func set_text(text: String) -> void:
	label.text = text


func play_bad_ending() -> void:
	pass


func play_good_ending() -> void:
	pass
