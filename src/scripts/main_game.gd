extends Node

const BAR = preload("uid://bvkn4awiardov")
const MIX = preload("uid://rswunmjp4n4w")
const SHAKE = preload("uid://o5s672jcawx5")
const TOPPING = preload("uid://co61gy3pe3qm8")
const FIGHT = preload("uid://duk7ril5efser")
const DRINK_SELECTED_MENU = preload("uid://c3b0oklocj8vt")
const TOPPING_SELECTED_MENU = preload("uid://v4kgp8fow7ge")
const END_SCREEN = preload("uid://chcpsepuxd1sy")
const MAIN_MENU = preload("uid://gngnsmd71vbo")

@onready var dialogue: Dialogue = %Dialogue as Dialogue
@onready var gui: CanvasLayer = %GUI
@onready var scene_switcher: SceneSwitcher = %SceneSwitcher as SceneSwitcher
@onready var world: Node2D = %World
@onready var mix_menu: MixMenu = %MixMenu as MixMenu
@onready var topping_menu: ToppingMenu = %ToppingMenu as ToppingMenu

var customer_num: int = 0 # which customer is the player on?
var current_ghost: Classes.Ghost

var current_scene: Node2D

enum DrinkStation {
	MIX,
	TOPPING,
}

var current_drink_station: DrinkStation = DrinkStation.MIX

## Stores the drink that the player is making.
var current_drink := Classes.Drink.new()

## Stores the player's score. Positive is good, negative is bad.
var reputation := 0

## Automatically sets the window to fullscreen on mouse click for web builds.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _ready() -> void:
	# Sets up custom mouse cursors
	var cursor_idle = preload("uid://dhcdqy41eqhsh")
	var cursor_interactable = preload("uid://coevld4vpf17c")
	
	Input.set_custom_mouse_cursor(cursor_idle)
	Input.set_custom_mouse_cursor(cursor_interactable, Input.CURSOR_POINTING_HAND)
	
	var main_menu: MainMenu = MAIN_MENU.instantiate()
	main_menu.start.connect(_start_game)
	main_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	world.add_child(main_menu)
	
	# Sets up the music.
	AudioManager.play_background_jazz()


func _start_game() -> void:
	# Removes the MainMenu scene, which shouldn't be assigned to current_scene because it's not a Node2D.
	# There's not really a reason for it, I guess I could just make current_scene a Node instead.
	world.get_child(0).queue_free()
	
	# Sets up the bar.
	current_scene = BAR.instantiate()
	world.add_child(current_scene)
	scene_switcher.set_pointing_to("drinks")
	scene_switcher.show()
	dialogue.show()
	
	# Sets up the first customer as the pirate.
	select_new_ghost(ghost_db.pirate)


## Selects a new (optionally random) customr and changes the dialogue text.
func select_new_ghost(p_ghost: Classes.Ghost = null) -> void: 
	# Assigns the ghost to the parameter ghost.
	var chosen_ghost: Classes.Ghost = p_ghost
	
	# Checks if the parameter ghost wasn't specified.
	if not p_ghost:
		# Picks a random ghost from the random_ghosts array.
		chosen_ghost = ghost_db.random_ghosts.pick_random()
		
		# Erases the chosen ghost from the array so they're not chosen again.
		ghost_db.random_ghosts.erase(chosen_ghost)
	
	# Initializes the current_ghost object.
	current_ghost = Classes.Ghost.new(
		chosen_ghost.name,
		chosen_ghost.order,
		chosen_ghost.angry,
		chosen_ghost.happy,
		chosen_ghost.texture,
		Classes.Drink.new(
			chosen_ghost.drink.base,
			chosen_ghost.drink.topping
		)
	)
	
	# Sets up the dialogue using the current customer.
	dialogue.change_text(current_ghost.name, current_ghost.order)


## Switches the scene between the drinks station and the bar station.
## Not really useful outside of the scene switcher.
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
					new_scene.topping_selected.connect(_on_topping_topping_selected)
					new_scene.set_topping(current_drink.topping)
					topping_menu.show()
			
			# Hides the dialogue from the player since it's only meant for the bar scene.
			dialogue.hide()
			
			# Points the scene switcher to the bar.
			scene_switcher.set_pointing_to("bar")
			
		elif current_scene is Mix or current_scene is Topping:
			new_scene = BAR.instantiate() as Bar
			scene_switcher.set_pointing_to("drinks")
			
			# Sets the correct ghost texture.
			new_scene.set_ghost_texture(current_ghost.texture)
			
			# Shows and hides the menus for each scene.
			mix_menu.hide()
			topping_menu.hide()
			dialogue.show()
	
	world.add_child(new_scene)
	current_scene = new_scene


func _on_scene_switcher_scene_switched() -> void:
	switch_scene()


func _on_mix_drink_selected(drink_type: Classes.DrinkType) -> void:
	# Returns early to prevent new drinks from being added when the drink is full.
	if current_drink.base.size() == 3:
		return
	
	# Brings the drink towards the cup.
	(current_scene as Mix).move_drink()
	
	var drink_menu := DRINK_SELECTED_MENU.instantiate() as DrinkSelectedMenu
	
	# Connects the drink menu's pour function to pour the drink in the Mix scene and add it to the current_drink
	drink_menu.poured.connect(_on_drink_menu_poured)
	drink_menu.canceled.connect(_on_drink_menu_canceled)
	gui.add_child(drink_menu)
	
	# Sets the drink tooltip in the drink_menu.
	drink_menu.set_tooltip(TooltipDB.drink_database[drink_type].name, TooltipDB.drink_database[drink_type].info)
	
	# Disables the scene switcher so the player can't swap while selecting.
	scene_switcher.set_enabled(false)
	mix_menu.set_enabled(false)


func _on_drink_menu_poured() -> void:
	var mix_scene = current_scene as Mix
	var poured_drink: Classes.DrinkType = mix_scene.pour() as Classes.DrinkType
	
	# Increments the meter in the mix menu by one unit
	mix_menu.increment_meter()
	
	# Addes the poured drink into the list of bases
	current_drink.base.append(poured_drink)
		
	# Sets the cup sprite to look full.
	if current_drink.base.size() == 3:
		mix_scene.set_drink_sprite(true)

	# Shows the mix button by default, since pouring a unit implies that there is more than one unit in the drink.
	mix_menu.set_enabled(true)
	
	# Shows the scene switcher to allow the user to switch again.
	scene_switcher.set_enabled(true)


func _on_drink_menu_canceled() -> void:
	var mix_scene := current_scene as Mix
	mix_scene.cancel()
	
	# Shows the trash/mix buttons ONLY IF there is at least one base.
	# Without the base check, then the buttons will show up on cancel EVEN IF THERE IS NO BASE!
	if not current_drink.base.is_empty():
		mix_menu.set_enabled(true)
	
	# Shows the scene switcher to allow the user to switch again.
	scene_switcher.set_enabled(true)


## Resets the drink if the user trashes it or finishes the current customer.
## The method's kind of finicky right now because I wrote it when we only needed Mix scene logic,
## but now there's Topping scene logic to handle, too.
func reset_drink() -> void:
	var mix_scene := current_scene as Mix
	mix_scene.cancel()

	mix_menu.reset()
	
	# Empties the drink in the mix scene.
	mix_scene.set_drink_sprite(false)
	
	# Hides the topping menu if its showing.
	topping_menu.hide()
	
	# Plays short animation of old cup sliding away.
	mix_scene.replace_cup()
	
	# Resets the drink.
	current_drink = Classes.Drink.new()


func _on_mix_menu_mix_pressed() -> void:
	# Hides and resets the mix menu as it isn't necessary.
	mix_menu.hide()
	mix_menu.reset()
	
	# Prevents the player from switching scenes while the cup is sliding.
	scene_switcher.set_enabled(false)
	
	# Slides the cup out from the mix scene and waits until the slide is over.
	var mix_scene = current_scene as Mix
	await mix_scene.exit_cup()
	
	# Removes the mix scene.
	current_scene.queue_free()
	
	# Creates the new shake scene and connects signals.
	var shake_scene = SHAKE.instantiate() as Shake
	shake_scene.drink_shaken.connect(_on_shake_drink_shaken)
	
	# Assigns the new shake scene to the current_scene reference.
	current_scene = shake_scene
	
	world.add_child(current_scene)
	
	# Hides the switcher for player interaction, since players shouldn't be able to swap from the shaker.
	scene_switcher.hide()


func _on_shake_drink_shaken() -> void:
	# Removes the shake scene.
	current_scene.queue_free()
	
	# Creates the new topping scene and connects signals.
	var topping_scene = TOPPING.instantiate() as Topping
	topping_scene.topping_selected.connect(_on_topping_topping_selected)
	
	# Assigns the new topping scene to the current_scene reference.
	current_scene = topping_scene
	
	world.add_child(current_scene)
	
	# Slides the drink in from the left side of the screen.
	topping_scene.enter_drink()
	
	topping_menu.show()
	
	current_drink_station = DrinkStation.TOPPING
	
	# Shows the switcher for player interaction, since at this point it's hidden.
	scene_switcher.show()
	scene_switcher.set_enabled(true)


## Handles the player trashing their drink in the mixing station.
func _on_mix_menu_trash_pressed() -> void:
	reset_drink()


## Handles the player serving the drink from the topping menu.
func _on_topping_menu_serve_pressed() -> void:
	_handle_serve()


## Handles the player selecting a topping in the topping station.
func _on_topping_topping_selected(topping_type: Classes.ToppingType) -> void:
	# Returns early to prevent new topping from being added when the topping has already been placed.
	if current_drink.topping != Classes.ToppingType.NONE:
		return
	
	var main_topping_menu := TOPPING_SELECTED_MENU.instantiate() as ToppingSelectedMenu
	
	# Connects the drink menu's pour function to pour the drink in the Mix scene and add it to the current_drink
	main_topping_menu.used.connect(_on_topping_menu_used)
	main_topping_menu.canceled.connect(_on_topping_menu_canceled)
	gui.add_child(main_topping_menu)
	print_debug(topping_type)
	
	# Sets the drink tooltip in the topping_menu.
	main_topping_menu.set_tooltip(TooltipDB.topping_database[topping_type].name, TooltipDB.topping_database[topping_type].info)
	
	topping_menu.set_enabled(false)
	scene_switcher.set_enabled(false)


func _on_topping_menu_used() -> void:
	var topping_scene = current_scene as Topping
	var topping_used: Classes.ToppingType = topping_scene.top() as Classes.ToppingType
	
	# Adds the used topping into the drink.
	current_drink.topping = topping_used
	topping_scene.drop_topping()
	if current_drink.topping != Classes.ToppingType.NONE:
		pass # Do something here to only allow mixing in the Mix menu.
	
	topping_menu.set_enabled(true)
	scene_switcher.set_enabled(true)


func _on_topping_menu_canceled() -> void:
	var topping_scene := current_scene as Topping
	topping_scene.cancel()
	
	topping_menu.set_enabled(true)
	scene_switcher.set_enabled(true)


func _on_topping_menu_trash_pressed() -> void:
	# Sets the drink station so the scene switcher works.
	current_drink_station = DrinkStation.MIX
	
	# Frees the old topping scene, which is guaranteed to exist.
	current_scene.queue_free()
	
	# Makes the current scene the mix scene
	current_scene = MIX.instantiate() as Mix
	
	# Connects the signals to this script's methods.
	current_scene.drink_selected.connect(_on_mix_drink_selected)
	
	# Adds the mix scene back into the world node.
	world.add_child(current_scene)
	
	# Resets the drink.
	reset_drink()
	
	# Slides a new drink in.
	current_scene.enter_cup()
	
	# Shows the mix menu, which has already been reset.
	mix_menu.show()


## Handles the logic for the player serving the drink to the customer.
func _handle_serve() -> void:
	# Debug
	print_debug("Served!")
	
	# Stores the cup node to place it in front of the customer.
	var cup_node: Node2D = (current_scene as Topping).get_duplicated_cup_node()
	
	await (current_scene as Topping).exit_drink()
	
	# Swaps the scene back to the bar.
	switch_scene()
	
	(current_scene as Bar).place_cup(cup_node)
	
	# Prevents the player from switching scenes.
	scene_switcher.set_enabled(false)
	
	# Hides dialogue, since it is automatically shown upon switching.
	dialogue.hide()
	
	AudioManager.fade_background()
	
	# Holds the player in suspense. Was their drink good?
	await get_tree().create_timer(2).timeout
	
	# Checks whether the drink satisfies the order.
	var is_satisfied = test_drink()
	
	# Makes the ghost react to the drink. Good and bad reactions are similar.
	await (current_scene as Bar).react_to_drink(is_satisfied)
	
	# Debug
	print_debug(is_satisfied)
	
	# Changes the bar's reputation depending on the drink's quality.
	reputation += 1 if is_satisfied else -1
	
	if not is_satisfied:
		AudioManager.play_background_fight()
		
		# Sets up fight scene for negative reaction.
		var fight_scene = FIGHT.instantiate()
		
		# Connects the finished signal.
		fight_scene.finished.connect(_on_fight_fight_finished)
		
		# Gets rid of the bar scene to make way for the fight scene.
		current_scene.queue_free()
		
		# Sets the current_scene for easy access to the fight scene.
		current_scene = fight_scene
		
		world.add_child(fight_scene)
		
		scene_switcher.hide()
	else:
		_handle_post_reaction(is_satisfied)


## Tests whether the drink meets the current customer's standards.
func test_drink() -> bool:
	# TODO: Figure out logic for a correct drink, simplest way would be to
	# check if the drink matches exactly what the customer wanted.
	
	# Stores the actual drink's base for easy comparison.
	var current_base = current_drink.base
	
	# Stores the desired drink's base for easy comparison.
	var desired_base = current_ghost.drink.base
	
	# Stores the toppings for easy comparison.
	var current_topping = current_drink.topping
	var desired_topping = current_ghost.drink.topping
	
	# Stores whether the drink succeeds the comparison checks.
	var is_drink_good = false
	
	# Clears out the desired base using the current base to see if we satisfied the base requirement.
	for single_base in current_base:
		desired_base.erase(single_base)
	
	# Checks if the base is satisfied based on whether the desired_base array is empty.
	var is_base_satisfied := desired_base.is_empty()
	
	# Compares the hash of the bases to test for array equality
	# Drink MUST BE IDENTICAL to the desired drink.
	is_drink_good = is_base_satisfied and current_topping == desired_topping
	
	return is_drink_good


func _handle_ending() -> void:
	await (current_scene as Bar).exit_ghost()
	
	await get_tree().create_timer(2).timeout
	
	current_scene.queue_free()
	
	var end_screen: EndScreen = END_SCREEN.instantiate()
	
	gui.add_child(end_screen)
	
	# Decides which ending to play based on reputation at the end of the game.
	if reputation > 0:
		end_screen.play_good_ending()
	else:
		end_screen.play_bad_ending()


## Handles finishing the fight with the ghost.
func _on_fight_fight_finished() -> void:
	current_scene.queue_free()
	
	var bar_scene: Bar = BAR.instantiate()
	
	# Sets the texture again because we queue freed the previous instance of the bar scene.
	bar_scene.set_ghost_texture(current_ghost.texture)
	
	world.add_child(bar_scene)
	
	current_scene = bar_scene
	
	# Shows because the scene_switcher is hidden at this point.
	scene_switcher.show()
	
	_handle_post_reaction(false)


func _handle_post_reaction(satisfied: bool) -> void:
	AudioManager.play_background_jazz()
	
	if satisfied:
		dialogue.visible = true
		dialogue.change_text(current_ghost.name, current_ghost.happy)
	if not satisfied:
		dialogue.visible = true
		dialogue.change_text(current_ghost.name, current_ghost.angry)
	
	# Checks if there are more customers available. If not, game's over.
	if ghost_db.random_ghosts.size() == 0:
		_handle_ending()
		return
	
	# Lets the player read the dialogue.
	await get_tree().create_timer(3).timeout

	if satisfied:
		(current_scene as Bar).exit_cup()
	
	dialogue.visible = false
	
	# Selects a new ghost and changes the current_ghost global.
	select_new_ghost()
	
	# Swaps the customer using the new customer's texture, which should already be set at this point.
	# Awaits because the customer swapping takes some time.
	await (current_scene as Bar).swap_customer(current_ghost.texture)
	
	# Shows dialogue, since the player will need to see the order.
	dialogue.show()
	
	# Resets the drink station to the Mix station.
	current_drink_station = DrinkStation.MIX
	
	# Resets the current drink. SHOULD BE reset_drink() BUT THAT INCLUDES MIX SCENE BEHAVIOR!
	current_drink = Classes.Drink.new()
	
	# Allows the player to switch scenes again.
	scene_switcher.set_enabled(true)
