class_name MixMenu
extends Control

signal mix_pressed
signal trash_pressed

@onready var fill_meter: AnimatedSprite2D = %FillMeter
@onready var mix: TextureButton = %Mix
@onready var trash: TextureButton = %Trash

const meter_height = 810
const DISABLED_ALPHA_VALUE = 0.3

func _ready() -> void:
	loop_tween()


func loop_tween() -> void:
	await create_tween().tween_property(fill_meter, "position:y", meter_height + 10, 1).set_trans(Tween.TRANS_SINE).finished
	await create_tween().tween_property(fill_meter, "position:y", meter_height - 10, 1).set_trans(Tween.TRANS_SINE).finished
	loop_tween()


func set_meter(value: int) -> void:
	fill_meter.frame = value


func set_enabled(enabled: bool) -> void:
	mix.disabled = not enabled
	mix.modulate.a = 1.0 if enabled else DISABLED_ALPHA_VALUE
	
	trash.disabled = not enabled
	trash.modulate.a = 1.0 if enabled else DISABLED_ALPHA_VALUE


func increment_meter() -> void:
	fill_meter.frame += 1


func _on_mix_pressed() -> void:
	mix_pressed.emit()


func reset() -> void:
	set_enabled(false)
	set_meter(0)


func _on_trash_pressed() -> void:
	trash_pressed.emit()
