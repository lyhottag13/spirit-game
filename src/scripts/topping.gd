class_name Topping
extends Node2D

## Tells the main game what topping was selected for the title.
signal topping_selected(topping_type: String)

var selected_topping: Classes.ToppingType = Classes.ToppingType.NONE

var topping_textures: Dictionary[Classes.ToppingType, CompressedTexture2D] = {
	Classes.ToppingType.MINT: preload("uid://bifp8gvx3jsc5"),
	Classes.ToppingType.CHERRY: preload("uid://cyi7u3hhvxkme"),
	Classes.ToppingType.EYEBALL: preload("uid://cvyk85qlftnsw"),
	Classes.ToppingType.BLOOD: preload("uid://c3r3is2wdr17c"),
}

## Stores the topping placed if the player swaps between the bar and topping scenes.
var placed_topping: Classes.ToppingType

@onready var point: Marker2D = $Point
@onready var topping: Sprite2D = %Topping
@onready var glass_cup: Node2D = %GlassCup

func _ready() -> void:
	# Sets the topping's texture if the Main Game sets the topping before initialization
	if placed_topping:
		topping.texture = topping_textures[placed_topping]


func _on_topping_clicked(topping_type: Classes.ToppingType) -> void:
	# Returns early if the topping isn't NONE, since that means we're currently deciding to pour or cancel.
	if selected_topping != Classes.ToppingType.NONE:
		return
	
	selected_topping = topping_type
	ready_topping()
	# Emits the topping to MainGame.
	topping_selected.emit(topping_type)
	

## Tops the drink with the currently-selected topping.
func top() -> Classes.ToppingType:
	var topping_to_return = selected_topping
	
	# Assigns the added topping's texture to the topping sprite.
	topping.texture = topping_textures[selected_topping]
	

	return topping_to_return


## Cancels the topping and returns to a no-topping state.
func cancel() -> void:
	selected_topping = Classes.ToppingType.NONE


## Slides the drink in from the left side of the screen.
## Only required when the game is swapping from the shake to the topping scene.
func enter_drink() -> void:
	# Teleports the cup off the screen, since by default it's already in the center.
	glass_cup.position.x = -262
	
	await create_tween().tween_property(glass_cup, "position:x", DisplayServer.window_get_size().x / 2.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished

func exit_drink() -> void:
	await create_tween().tween_property(glass_cup, "position:x", DisplayServer.window_get_size().x + 300, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).finished


## Used by the Main Game to place the final cup in front of the customer.
## This is only really useful to display the topping, the cup liquid shouldn't change much.
func get_duplicated_cup_node() -> Node2D:
	return glass_cup.duplicate()


func set_topping(p_topping: Classes.ToppingType) -> void:
	placed_topping = p_topping
	
	
func ready_topping():
	topping.texture = topping_textures[selected_topping]
	topping.global_position = point.global_position
	
func drop_topping():
	await create_tween().tween_property(topping,"position:y",0,0.5).finished
