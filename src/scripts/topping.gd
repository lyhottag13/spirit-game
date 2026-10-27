class_name Topping
extends Node2D

## Tells the main game what topping was selected for the title.
signal topping_selected(topping_type: String)

var selected_topping: Classes.ToppingType = Classes.ToppingType.NONE

func _on_topping_clicked(topping_type: Classes.ToppingType) -> void:
	# Returns early if the topping isn't NONE, since that means we're currently deciding to pour or cancel.
	if selected_topping != Classes.ToppingType.NONE:
		return
	
	selected_topping = topping_type
	
	# Tells the MainGame what topping was selected
	match topping_type:
		_:
			topping_selected.emit("topping")


## Tops the drink with the currently-selected topping.
func top() -> Classes.ToppingType:
	var returned_topping = selected_topping
	selected_topping = Classes.ToppingType.NONE
	return returned_topping


## Cancels the topping and returns to a no-topping state.
func cancel() -> void:
	selected_topping = Classes.ToppingType.NONE
