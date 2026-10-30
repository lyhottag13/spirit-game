extends Node

const JAZZ = preload("uid://cvbmqo65qtg5p")
const FIGHT = preload("uid://cmhv1t16ux42l")

@onready var background: AudioStreamPlayer = %Background

func play_background_jazz() -> void:
	background.stream = JAZZ
	background.play()


func play_background_fight() -> void:
	background.stream = FIGHT
	background.play()


func stop_background() -> void:
	background.stop()


func fade_background(time_sec: float = 1.0) -> void:
	await create_tween().tween_property(background, "volume_linear", 0, time_sec).finished
	background.stop()
	background.volume_db = -19.5
