extends Node

const BAR = preload("uid://bvkn4awiardov")
const MIX = preload("uid://rswunmjp4n4w")
const TOPPING = preload("uid://co61gy3pe3qm8")
const DRINK_SELECTED_MENU = preload("uid://c3b0oklocj8vt")
const TOPPING_SELECTED_MENU = preload("uid://v4kgp8fow7ge")

@onready var gui: CanvasLayer = %GUI
@onready var scene_switcher: SceneSwitcher = $GUI/SceneSwitcher
@onready var world: Node2D = %World
@onready var mix_menu: MixMenu = $GUI/MixMenu as MixMenu
@onready var topping_menu: ToppingMenu = $GUI/ToppingMenu as ToppingMenu

var current_scene: Node2D

enum DrinkStation {
	MIX,
	TOPPING,
}

var current_drink_station: DrinkStation = DrinkStation.MIX

enum ToppingType {
	TOPPING1,
	TOPPING2,
	TOPPING3,
	TOPPING4,
	NONE, # Required as it's impossible to assign null to an enum-type var
}

enum DrinkType {
	VODKA,
	SYRUP,
	BRANDY,
	WHISKEY,
	GIN,
	RUM,
	NONE, # Required as it's impossible to assign null to an enum-type var
}

class Drink:
	var base: Array = []
	var topping: ToppingType = ToppingType.NONE


var current_drink := Drink.new()

var current_desired_drink: Drink

var reputation := 0

func _ready() -> void:
	current_scene = BAR.instantiate()
	world.add_child(current_scene)
	scene_switcher.set_pointing_to("drinks")
	
	var ghost_drink := ghost_db.ghosts["pirate"]["drink"] as Dictionary
	var ghost_base = ghost_drink.base as Array[DrinkType]
	print_debug(ghost_drink.base)
	
	# Initializes the desired drink with the pirate's desired drink.
	current_desired_drink = Drink.new()
	current_desired_drink.base = ghost_base
	#current_desired_drink.base = [DrinkType.RUM, DrinkType.RUM, DrinkType.RUM]
	current_desired_drink.topping = ghost_drink.topping


func switch_scene():
	var new_scene: Node2D
	
	if current_scene:
		current_scene.queue_free()
	
	# This is kind of confusing, but we're matching where we're swapping FROM, not TO.
		if current_scene is Bar:
			
			# Loads either the mix or topping stations, depending on which one is needed.
			match current_drink_station:
				DrinkStation.MIX:
					new_scene = MIX.instantiate() as Mix
					new_scene.drink_selected.connect(_on_mix_drink_selected)
					mix_menu.show()
					
				DrinkStation.TOPPING:
					new_scene = TOPPING.instantiate() as Topping
					topping_menu.show()
					
			scene_switcher.set_pointing_to("bar")
			
		elif current_scene is Mix or current_scene is Topping:
			new_scene = BAR.instantiate() as Bar
			scene_switcher.set_pointing_to("drinks")
			
			mix_menu.hide()
			topping_menu.hide()
	
	world.add_child(new_scene)
	current_scene = new_scene


func _on_scene_switcher_scene_switched() -> void:
	switch_scene()


func _on_mix_drink_selected(drink_type: String) -> void:
	# Returns early to prevent new drinks from being added when the drink is full.
	if current_drink.base.size() == 3:
		return
	
	var drink_menu := DRINK_SELECTED_MENU.instantiate() as DrinkSelectedMenu
	
	# Connects the drink menu's pour function to pour the drink in the Mix scene and add it to the current_drink
	drink_menu.poured.connect(_on_drink_menu_poured)
	drink_menu.canceled.connect(_on_drink_menu_canceled)
	gui.add_child(drink_menu)
	
	# Sets the drink tooltip in the drink_menu.
	drink_menu.set_tooltip(drink_type.capitalize(), "Default")
	
	# Hides the scene switcher so the player can't swap while selecting.
	scene_switcher.hide()
	mix_menu.set_button_visibility(false)


func _on_drink_menu_poured() -> void:
	var mix_scene = current_scene as Mix
	var poured_drink: DrinkType = mix_scene.pour() as DrinkType
	
	# Increments the meter in the mix menu by one unit
	mix_menu.increment_meter()
	
	# Addes the poured drink into the list of bases
	current_drink.base.append(poured_drink)
	
	# Shows the mix button by default, since pouring a unit implies that there is more than one unit in the drink.
	mix_menu.set_button_visibility(true)
	
	# Sets the cup sprite to look full.
	if current_drink.base.size() == 3:
		mix_scene.set_drink_sprite(true)
	
	# Shows the scene switcher to allow the user to switch again.
	scene_switcher.show()
	mix_menu.set_button_visibility(true)


func _on_drink_menu_canceled() -> void:
	var mix_scene := current_scene as Mix
	mix_scene.cancel()
	
	# Shows the trash/mix buttons ONLY IF there is at least one base.
	# Without the base check, then the buttons will show up on cancel EVEN IF THERE IS NO BASE!
	if not current_drink.base.is_empty():
		mix_menu.set_button_visibility(true)
	
	# Shows the scene switcher to allow the user to switch again.
	scene_switcher.show()


## Resets the drink if the user trashes it or finishes the current customer.
func reset_drink() -> void:
	var mix_scene := current_scene as Mix
	mix_scene.cancel()
	mix_menu.set_button_visibility(false)
	mix_menu.reset()
	
	# Empties the drink in the mix scene.
	mix_scene.set_drink_sprite(false)
	
	# Hides the topping menu if its showing.
	topping_menu.hide()
	
	# Plays short animation of old cup sliding away.
	mix_scene.replace_cup()
	
	# Resets the drink.
	current_drink = Drink.new()


func _on_mix_menu_mix_pressed() -> void:
	current_scene.queue_free()
	current_scene = TOPPING.instantiate() as Topping
	current_scene.topping_selected.connect(_on_topping_topping_selected)
	world.add_child(current_scene)
	
	mix_menu.hide()
	mix_menu.reset()
	
	topping_menu.show()
	
	current_drink_station = DrinkStation.TOPPING


## Handles the player trashing their drink in the mixing station.
func _on_mix_menu_trash_pressed() -> void:
	reset_drink()


## Handles the player serving the drink from the topping menu.
func _on_topping_menu_serve_pressed() -> void:
	_handle_serve()


## Handles the player selecting a topping in the topping station.
func _on_topping_topping_selected(topping_type: String) -> void:
	# Returns early to prevent new topping from being added when the topping has already been placed.
	if current_drink.topping != ToppingType.NONE:
		return
	
	var main_topping_menu := TOPPING_SELECTED_MENU.instantiate() as ToppingSelectedMenu
	
	# Connects the drink menu's pour function to pour the drink in the Mix scene and add it to the current_drink
	main_topping_menu.used.connect(_on_topping_menu_used)
	main_topping_menu.canceled.connect(_on_topping_menu_canceled)
	gui.add_child(main_topping_menu)
	print_debug(topping_type)
	# Sets the drink tooltip in the topping_menu.
	main_topping_menu.set_tooltip(topping_type.capitalize(), "Default")


func _on_topping_menu_used() -> void:
	var topping_scene = current_scene as Topping
	var topping_used: ToppingType = topping_scene.top() as ToppingType
	
	# Adds the used topping into the drink.
	current_drink.topping = topping_used
	
	if current_drink.topping != ToppingType.NONE:
		pass # Do something here to only allow mixing in the Mix menu.


func _on_topping_menu_canceled() -> void:
	var topping_scene := current_scene as Topping
	topping_scene.cancel()


func _on_topping_menu_trash_pressed() -> void:
	current_drink_station = DrinkStation.MIX
	
	# Frees the old topping scene, which is guaranteed to exist.
	current_scene.queue_free()
	
	# Makes the current scene the mix scene
	current_scene = MIX.instantiate() as Mix
	
	# Adds the mix scene back into the world node.
	world.add_child(current_scene)
	
	# Resets the drink.
	reset_drink()
	
	# Connects the signals to this script's methods.
	current_scene.drink_selected.connect(_on_mix_drink_selected)
	
	# Shows the mix menu, which has already been reset.
	mix_menu.show()


## Handles the logic for the player serving the drink to the customer.
func _handle_serve() -> void:
	# Debug
	print_debug("Served!")
	
	# Swaps the scene back to the bar.
	switch_scene()
	
	# Prevents the player from switching scenes.
	scene_switcher.hide()
	
	# Checks whether the drink satisfies the order.
	var is_satisfied = test_drink()
	
	# Debug
	print_debug(is_satisfied)
	
	# Changes the reputation depending on the drink's quality.
	reputation += 1 if is_satisfied else -1
	
	# Resets the drink station to the Mix station.
	current_drink_station = DrinkStation.MIX
	
	# Casts for error handling, even though current_scene should always be Bar.
	var bar_scene := current_scene as Bar
	
	# REPLACE!!! We should be loading the incoming customer's PNG here.
	await bar_scene.swap_customer(load("res://src/resources/images/Pirate_Ghost.png"))
	
	# Resets the current drink. SHOULD BE reset_drink() BUT THAT INCLUDES MIX SCENE BEHAVIOR!
	current_drink = Drink.new()
	
	# Allows the user to switch scenes again.
	scene_switcher.show()


## Tests whether the drink meets the current customer's standards.
func test_drink() -> bool:
	# TODO: Figure out logic for a correct drink, simplest way would be to
	# check if the drink matches exactly what the customer wanted.
	
	# Stores the actual drink's base and sorts it for easy comparison.
	var current_base = current_drink.base
	current_base.sort()
	
	# Stores the desired drink's base and sorts it for easy comparison.
	var desired_base = current_desired_drink.base
	desired_base.sort()
	
	# Stores the toppings for easy access.
	var current_topping = current_drink.topping
	var desired_topping = current_desired_drink.topping
	
	# Compares the hash of the bases to test for array equality
	var is_drink_good = current_base.hash() == desired_base.hash() and current_topping == desired_topping
	
	return is_drink_good
