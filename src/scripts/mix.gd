class_name Mix
extends Node2D

## Tells the main game what drink was selected for the title.
signal drink_selected(drink_type: String)

enum Drinks {
	VODKA,
	SYRUP,
	BRANDY,
	WHISKEY,
	GINGER,
	RUM,
	NONE, # Required as it's impossible to assign null to an enum-type var
}

@onready var cup: AnimatedSprite2D = %Cup

var selected_drink: Drinks = Drinks.NONE

func _on_drink_clicked(drink_type: Drinks) -> void:
	# Returns early if the drink isn't NONE, since that means we're currently deciding to pour or cancel.
	if not selected_drink == Drinks.NONE:
		return
	
	selected_drink = drink_type
	
	# Tells the MainGame what drink was selected
	match drink_type:
		Drinks.VODKA:
			drink_selected.emit("vodka")
		Drinks.SYRUP:
			drink_selected.emit("syrup")
		Drinks.BRANDY:
			drink_selected.emit("brandy")
		Drinks.WHISKEY:
			drink_selected.emit("whiskey")
		Drinks.GINGER:
			drink_selected.emit("ginger")
		Drinks.RUM:
			drink_selected.emit("rum")


func pour() -> Drinks:
	var returned_drink = selected_drink
	selected_drink = Drinks.NONE
	return returned_drink


func cancel() -> void:
	selected_drink = Drinks.NONE


## Sets the fullness of the drink on the counter. If the cup is full, then we set
## the cup to the full frame of the sprite frame, otherwise we set it to the empty one.
func set_drink_sprite(full: bool) -> void:
	cup.frame = 1 if full else 0


func replace_cup() -> void:
	const CUP_DISPLACEMENT = 200
	const SLIDE_TIME = 0.4
	await create_tween().tween_property(cup, "position:x", DisplayServer.window_get_size().x + CUP_DISPLACEMENT, SLIDE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished
	cup.position.x = -CUP_DISPLACEMENT
	await create_tween().tween_property(cup, "position:x", DisplayServer.window_get_size().x / 2.0, SLIDE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished
