class_name Dialogue
extends Control

@onready var name_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/NameLabel
@onready var order_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/OrderLabel

func change_text(p_name: String, p_order: String):
	name_label.text = p_name
	order_label.text = p_order
