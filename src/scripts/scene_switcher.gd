class_name SceneSwitcher
extends Control

signal scene_switched()

const DRINKS_1 = preload("uid://bhltcois26yc6")
const DRINKS_2 = preload("uid://b0c8blklwbx54")
const BAR_1 = preload("uid://jy6cqvhma6mi")
const BAR_2 = preload("uid://cnjm2ttu8aor7")
const DISABLED_ALPHA_VALUE = 0.3

@onready var switcher: TextureButton = $Switcher

func _ready() -> void:
	switcher.position.x += 400


func _on_switcher_pressed() -> void:
	scene_switched.emit()


## Sets where the arrow is currently pointing to.
## Only two values should be available here, "bar" and "drinks".
func set_pointing_to(pointing_to: String) -> void:
	match pointing_to:
		"bar":
			switcher.texture_normal = BAR_1
			switcher.texture_hover = BAR_2
			switcher.set_anchors_preset(Control.PRESET_CENTER_LEFT, true)
			switcher.position.x += 400
		"drinks":
			switcher.texture_normal = DRINKS_1
			switcher.texture_hover = DRINKS_2
			switcher.set_anchors_preset(Control.PRESET_CENTER_RIGHT, true)
			switcher.position.x -= 400


func set_enabled(enabled: bool) -> void:
	switcher.disabled = not enabled
	switcher.modulate.a = 1.0 if enabled else DISABLED_ALPHA_VALUE
