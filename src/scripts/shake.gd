class_name Shake
extends Node2D

signal drink_shaken

enum ShakePosition {
	LEFT,
	RIGHT,
}

## Stores the number of shakes that are required for a drink.
const TARGET_SHAKES = 10

var shaker_tween: Tween

## Tracks how many times a drink has been shaken.
var number_of_shakes: int

## Tracks where the shaker currently is.
var shake_position: ShakePosition = ShakePosition.RIGHT

@onready var shaker: Sprite2D = %Shaker

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shake_left") and shake_position == ShakePosition.RIGHT:
		_handle_shake(ShakePosition.LEFT)
	if Input.is_action_just_pressed("shake_right"):
		_handle_shake(ShakePosition.RIGHT)

func _handle_shake(p_shake_position: ShakePosition) -> void:
	# Early returns if we're shaking back to the same position.
	if shake_position == p_shake_position:
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
	drink_shaken.emit()
	print_debug("Emitted!")
