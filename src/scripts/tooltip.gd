class_name Tooltip
extends Control

@onready var title: Label = %Title
@onready var information: RichTextLabel = %Information

func set_title(p_title: String) -> void:
	
	title.text = p_title

func set_information(p_information: String) -> void:
	# Sets the text to start with a BBCCode unorder list starter.
	information.text = "[ul]%s" % p_information
