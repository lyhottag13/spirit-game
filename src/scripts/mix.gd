class_name Mix
extends Node2D

## Tells the main game what drink was selected for the title.
signal drink_selected(drink_type: String)

enum Drinks {
	VODKA,
	SYRUP,
	BLOOD,
	WHISKEY,
	GINGER,
	RUM,
	NONE, # Required as it's impossible to assign null to an enum-type var
}

## Time in seconds for the drink to come to the cup when selected.
const SELECT_TIME = 0.2

## Stores where the bottle is supposed to go.
const FUTURE_DRINK_POSITION = Vector2(876, 333)

## Stores the old drink position when a drink is selected.
var old_drink_position: Vector2

## Stores the bottle's old scale value, since it varies between bottles.
var old_scale: Vector2

## Stores the current bottle button selected
var selected_bottle: TextureButton


## Stores the drink TYPE selected.
var selected_drink: Drinks = Drinks.NONE

## Stores the bottle's tween for easy killing.
var bottle_tween: Tween

@onready var cup: AnimatedSprite2D = %Cup

func _on_drink_clicked(button: TextureButton, drink_type: Drinks) -> void:
	# Returns early if the drink isn't NONE, since that means we're currently deciding to pour or cancel.
	if not selected_drink == Drinks.NONE:
		return
	
	selected_drink = drink_type
	selected_bottle = button
	
	# TODO: Fix bug associated with a bug when you spam the cancel -> rum sequence,
	# the rum bottle with think its old_drink_position is the position during the tween.
	old_drink_position = selected_bottle.position
	old_scale = selected_bottle.scale
	
	var name_to_emit: String
	
	# Tells the MainGame what drink was selected
	match drink_type:
		Drinks.VODKA:
			name_to_emit = "vodka"
		Drinks.SYRUP:
			name_to_emit = "syrup"
		Drinks.BLOOD:
			name_to_emit = "blood"
		Drinks.WHISKEY:
			name_to_emit = "whiskey"
		Drinks.GINGER:
			name_to_emit = "ginger"
		Drinks.RUM:
			name_to_emit = "rum"
	
	drink_selected.emit(name_to_emit)
	
	# Moves the selected drink down on the scene tree so it overlaps the other drinks.
	move_child(button, -2)


func pour() -> Drinks:
	var returned_drink = selected_drink
	selected_drink = Drinks.NONE
	
	_reset_cup_transforms()
	
	return returned_drink


func cancel() -> void:
	selected_drink = Drinks.NONE
	
	_reset_cup_transforms()


## Moves the selected drink smoothly towards the cup.
func move_drink() -> void:
	# Kills the bottle_tween so that the repositioning doesn't bug the bottle.
	if bottle_tween and bottle_tween.is_valid():
		bottle_tween.kill()
	
	# Creates the tween to move the bottle towards the cup.
	bottle_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	bottle_tween.tween_property(selected_bottle, "position", FUTURE_DRINK_POSITION, SELECT_TIME)
	bottle_tween.parallel().tween_property(selected_bottle, "scale", Vector2(1.4, 1.4), SELECT_TIME)
	bottle_tween.parallel().tween_property(selected_bottle, "rotation_degrees", -54, SELECT_TIME)


func _reset_cup_transforms() -> void:
	# Kills the bottle_tween so that the repositioning doesn't bug the bottle.
	if bottle_tween and bottle_tween.is_valid():
		bottle_tween.kill()
	
	# Repositions the bottle.
	bottle_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	bottle_tween.tween_property(selected_bottle, "position", old_drink_position, SELECT_TIME)
	bottle_tween.parallel().tween_property(selected_bottle, "scale", old_scale, SELECT_TIME)
	bottle_tween.parallel().tween_property(selected_bottle, "rotation_degrees", 0, SELECT_TIME)


## Sets the fullness of the drink on the counter. If the cup is full, then we set
## the cup to the full frame of the sprite frame, otherwise we set it to the empty one.
func set_drink_sprite(full: bool) -> void:
	cup.frame = 1 if full else 0


const CUP_DISPLACEMENT = 200
const SLIDE_TIME = 0.4

func replace_cup() -> void:
	await exit_cup()
	await enter_cup()


## Separate method for the cup entering because we can use this when swapping into the mix scene.
func enter_cup() -> void:
	cup.position.x = -CUP_DISPLACEMENT
	await create_tween().tween_property(cup, "position:x", DisplayServer.window_get_size().x / 2.0, SLIDE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished

## Separate method for the cup exiting because we can use this when swapping to the topping scene.
func exit_cup() -> void:
	await create_tween().tween_property(cup, "position:x", DisplayServer.window_get_size().x + CUP_DISPLACEMENT, SLIDE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished
