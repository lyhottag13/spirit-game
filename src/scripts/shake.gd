class_name Shake
extends Node2D

signal drink_shaken

enum ShakePosition {
	LEFT,
	RIGHT,
}

## Stores the number of shakes that are required for a drink.
const TARGET_SHAKES = 11

var shaker_tween: Tween

## Tracks how many times a drink has been shaken.
var number_of_shakes: int

## Tracks whether the drink is done shaking.
var is_drink_done: bool = false

## Tracks where the shaker currently is.
var shake_position: ShakePosition = ShakePosition.RIGHT

@onready var shaker: Sprite2D = %Shaker
@onready var glass_cup: Node2D = %GlassCup
@onready var button_tutorial: AnimatedSprite2D = %ButtonTutorial

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shake_left"):
		_handle_shake(ShakePosition.LEFT)
	if Input.is_action_just_pressed("shake_right"):
		_handle_shake(ShakePosition.RIGHT)

func _handle_shake(p_shake_position: ShakePosition) -> void:
	# Early returns if we're shaking back to the same position.
	if shake_position == p_shake_position:
		return
	
	# Early returns if the drink is already done shaking.
	if is_drink_done:
		return
	
	# Sets up the new shaker tween.
	shaker_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Moves the shaker to the new shake position.
	shaker_tween.tween_property(shaker, "position:x", shaker.position.x + (200 if p_shake_position == ShakePosition.RIGHT else -200), 0.3)
	
	# Assigns the current shake position to the new shake position.
	shake_position = p_shake_position
	
	# Increments the number of shakes on a successful shake.
	number_of_shakes += 1
	
	# Ends the shaking sequence if the drink has been shaken a certain number of times.
	if number_of_shakes == TARGET_SHAKES:
		_handle_drink_done()

func _handle_drink_done() -> void:
	# Sets a flag to prevent the player from shaking the shaker.
	is_drink_done = true
	
	_hide_tutorial()
	
	const SLIDE_TIME = 0.4
	
	# Copied straight from Mix.enter_cup()
	await create_tween().tween_property(glass_cup, "position:x", DisplayServer.window_get_size().x / 2.0, SLIDE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished
	
	# Pours the drink into the cup.
	await create_tween().tween_property(shaker, "rotation_degrees", -110, 2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).finished
	
	# Copied straight from Mix.exit_cup()
	await create_tween().tween_property(glass_cup, "position:x", DisplayServer.window_get_size().x + 600, SLIDE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished
	
	drink_shaken.emit()


func _hide_tutorial() -> void:
	button_tutorial.hide()
