class_name EndScreen
extends Control

@onready var label: Label = %Label
@onready var bad_end_panels: Node2D = %BadEndPanels
@onready var good_end_panels: Node2D = %GoodEndPanels

func play_bad_ending() -> void:
	_play_panels(bad_end_panels.get_children())


func play_good_ending() -> void:
	_play_panels(good_end_panels.get_children())


func _play_panels(panels: Array[Node]) -> void:
	var ending_tween = create_tween()
	for panel: AnimatedSprite2D in panels:
		ending_tween.tween_property(panel, "modulate:a", 1, 2)
		ending_tween.tween_interval(2)
