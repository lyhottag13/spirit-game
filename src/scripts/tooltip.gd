class_name Tooltip
extends Control

@onready var title: Label = %Title
@onready var information: Label = %Information

func set_title(p_title: String) -> void:
	
	title.text = p_title

func set_information(p_information: String) -> void:
	information.text = p_information
