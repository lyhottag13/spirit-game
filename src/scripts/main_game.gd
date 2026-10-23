extends Node

const BAR = preload("uid://bvkn4awiardov")
const MIX = preload("uid://rswunmjp4n4w")
const TOPPING = preload("uid://co61gy3pe3qm8")
const DRINK_SELECTED_MENU = preload("uid://c3b0oklocj8vt")
const TOPPING_SELECTED_MENU = preload("uid://v4kgp8fow7ge")
@onready var dialogue: Control = $GUI/Dialogue

@onready var gui: CanvasLayer = %GUI
@onready var scene_switcher: SceneSwitcher = $GUI/SceneSwitcher
@onready var world: Node2D = %World
@onready var mix_menu: MixMenu = $GUI/MixMenu as MixMenu
@onready var topping_menu: ToppingMenu = $GUI/ToppingMenu
var customer_num: int = 0 # which customer is the player on?
var customer_list = ["pirate"] # var for storing order of customer
var current_customer: Customer
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
	TEQUILA,
	BRANDY,
	WHISKEY,
	GIN,
	RUM,
	NONE, # Required as it's impossible to assign null to an enum-type var
}

class Drink:
	var base: Array[DrinkType] = []
	var topping: ToppingType = ToppingType.NONE

class Customer:
	var name : String
	var text: String

var current_drink = Drink.new()

func _ready() -> void:
	current_scene = BAR.instantiate()
	world.add_child(current_scene)
	scene_switcher.set_pointing_to("drinks")
	
func new_customer(): #makes current customer object and sets order text 
	var ghost = ghost_db.ghosts[customer_list[customer_num]]
	current_customer = Customer.new()
	current_customer.text = ghost["order"]
	current_customer.name = customer_list[customer_num]
	dialogue.change_text(current_customer.text)
	

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
					
			scene_switcher.set_pointing_to("bar")
			
		elif current_scene is Mix or current_scene is Topping:
			new_scene = BAR.instantiate() as Bar
			scene_switcher.set_pointing_to("drinks")
			
			mix_menu.hide()
	
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


func _on_drink_menu_poured() -> void:
	var mix_scene = current_scene as Mix
	var poured_drink: DrinkType = mix_scene.pour() as DrinkType
	
	# Increments the meter in the mix menu by one unit
	mix_menu.increment_meter()
	
	# Addes the poured drink into the list of bases
	current_drink.base.append(poured_drink)

	# Shows the mix button by default, since pouring a unit implies that there is more than one unit in the drink.
	mix_menu.set_button_visibility(true)


	if current_drink.base.size() == 3:
		pass # Do something here to only allow mixing in the Mix menu.


func _on_drink_menu_canceled() -> void:
	var mix_scene := current_scene as Mix
	mix_scene.cancel()


## Resets the drink if the user trashes it or finishes the current customer.
func reset_drink() -> void:
	var mix_scene = current_scene as Mix
	mix_scene.cancel()
	mix_menu.set_button_visibility(false)
	mix_menu.reset()
	
	# If the topping menu is showing, it's now hidden.
	topping_menu.hide()
	
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
	topping_menu.hide()
	topping_menu.reset()

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
