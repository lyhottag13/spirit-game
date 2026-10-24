## Drink pouring zone of the ghost bar game.
##
## Controls the row of drink buttons, lifts the clicked drink to a "ready" spot,
## plays the pour animation, and returns the drink to its shelf position.
## Also switches the cup sprite between empty and full.
##
## This script only handles what you see in the Mix scene. Game state (the current
## drink, the fill meter, the popup menu) lives in the main game script, which talks
## to Mix through the drink_selected signal and the pour(), cancel() and
## set_drink_sprite() methods.
##
## The "ready" positions come from the Marker2D nodes under ReadyMarkers.

# ==============================================================================
# HOW TO ADD A NEW DRINK (example: Absinthe)
# ==============================================================================
# Every step touches one of three places: the Mix scene, this script, and the
# main game script.
#
# ------------------------------------------------------------------------------
# 1. ADD THE BUTTON (Mix scene)
# ------------------------------------------------------------------------------
#    - Select the Rum button, press Ctrl+D, and rename the copy to "Absinthe".
#    - Swap its textures and drag it to its shelf position.
#    - Keep it directly under Mix. Do NOT put it inside a container node, or the
#      tweens will fight the layout.
#
# ------------------------------------------------------------------------------
# 2. CONNECT ITS CLICK SIGNAL (Node dock > Signals tab)
# ------------------------------------------------------------------------------
#    - Look at how Rum is connected to _on_drink_clicked. It binds a Drinks enum
#      number.
#    - Connect Absinthe the same way and bind the NEW number (6 if added last).
#    - If you duplicated the button, edit the copied connection. Otherwise the
#      Absinthe button will pour rum.
#
# ------------------------------------------------------------------------------
# 3. ADD IT TO THE Drinks ENUM (this script)
# ------------------------------------------------------------------------------
#    Put it above NONE. Adding at the end keeps the existing numbers, so the
#    existing editor connections keep working.
#
#        enum Drinks {
#            VODKA, SYRUP, BRANDY, WHISKEY, GINGER, RUM,
#            ABSINTHE,   # new, becomes 6
#            NONE,       # shifts from 6 to 7
#        }
#
# ------------------------------------------------------------------------------
# 4. ADD A READY MARKER (Mix scene)
# ------------------------------------------------------------------------------
#    Under ReadyMarkers, add a Marker2D named "Absinthe" and drag it to where the
#    drink should hover when selected.
#
# ------------------------------------------------------------------------------
# 5. ADD IT TO BOTH DICTIONARIES (this script)
# ------------------------------------------------------------------------------
#        drinks_dict:   Drinks.ABSINTHE: $Absinthe,
#        ready_markers: Drinks.ABSINTHE: $ReadyMarkers/Absinthe,
#
#    Being in drinks_dict applies the pivot setup in _ready() automatically.
#    The lift, pour and cancel animations need no changes.
#
# ------------------------------------------------------------------------------
# 6. ADD ITS match BRANCH (in _on_drink_clicked)
# ------------------------------------------------------------------------------
#        Drinks.ABSINTHE:
#            drink_selected.emit("absinthe")
#
#    The main game uses this string for the popup title, so spell it the way you
#    want it displayed.
#
# ------------------------------------------------------------------------------
# 7. UPDATE THE MAIN GAME SCRIPT
# ------------------------------------------------------------------------------
#    Its DrinkType enum must list drinks in the SAME ORDER as Drinks here, because
#    pour() is cast with "as DrinkType". Add ABSINTHE in the same position (above
#    NONE). If the orders differ, a poured drink is recorded as the wrong one and
#    ghost orders will never match.
#
# ------------------------------------------------------------------------------
# 8. UPDATE THE GHOST DATA (only if a ghost orders it)
# ------------------------------------------------------------------------------
#    Recipes use the same lowercase string from step 6:
#
#        "drink": {
#            "base": ["absinthe", "rum", "rum"],
#            "topping": ToppingType.TOPPING1
#        }
# ==============================================================================

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

# --- Tweak these in the Inspector ---
@export var ready_rotation_deg := 20.0
@export var pour_rotation_deg := 110.0   # flip the sign if it tips the wrong way
@export var move_time := 0.3
@export var tilt_time := 0.25
@export var pour_hold_time := 0.8

@onready var cup: AnimatedSprite2D = %Cup

# Maps each drink enum to its drink node. Change the paths to match your scene.
@onready var drinks_dict: Dictionary = {
	Drinks.VODKA: $Vodka,
	Drinks.SYRUP: $Syrup,
	Drinks.BRANDY: $Brandy,
	Drinks.WHISKEY: $Whiskey,
	Drinks.GINGER: $Ginger,
	Drinks.RUM: $Rum,
}

# Maps each drink enum to the Marker2D it lifts to. Move the markers in the scene view.
@onready var ready_markers: Dictionary = {
	Drinks.VODKA: $ReadyMarkers/Vodka,
	Drinks.SYRUP: $ReadyMarkers/Syrup,
	Drinks.BRANDY: $ReadyMarkers/Brandy,
	Drinks.WHISKEY: $ReadyMarkers/Whiskey,
	Drinks.GINGER: $ReadyMarkers/Ginger,
	Drinks.RUM: $ReadyMarkers/Rum,
}

var selected_drink_enum: Drinks = Drinks.NONE
var selected_drink_object: Control   # TextureButtons, which extend Control

# Cached "home" state of the selected drink.
var home_position: Vector2
var home_rotation_deg: float
var home_z: int

var tween: Tween
var busy := false  # true while a drink is animating back home


func _ready() -> void:
	# Stops any autoplaying animation so set_drink_sprite() controls the frame.
	cup.stop()
	
	# Sets the rotation pivot point of each drink object. Without it the drinks would rotate differently.
	for drink_object: Control in drinks_dict.values():
		var new_pivot := drink_object.size / 2.0
		var old_pivot := drink_object.pivot_offset
		
		# Subtracts the shift caused by moving the pivot, so the drink stays where the scene view shows it.
		drink_object.position -= (new_pivot - old_pivot) * (Vector2.ONE - drink_object.scale)
		drink_object.pivot_offset = new_pivot


func _on_drink_clicked(drink_type: Drinks) -> void:
	# Ignore clicks while deciding pour/cancel, or while a drink is still returning.
	if selected_drink_enum != Drinks.NONE or busy:
		return
	
	selected_drink_enum = drink_type
	selected_drink_object = drinks_dict[drink_type]
	
	# Cache where the drink came from so we can put it back.
	home_position = selected_drink_object.position
	home_rotation_deg = selected_drink_object.rotation_degrees
	home_z = selected_drink_object.z_index
	
	# Draw the lifted drink on top of everything else.
	selected_drink_object.z_index = 100
	
	# This drink's marker, converted into this scene's coordinates.
	# Subtracting the pivot makes the marker mark the drink's center, not its top-left corner.
	var marker: Marker2D = ready_markers[drink_type]
	var target := to_local(marker.global_position) - selected_drink_object.pivot_offset
	
	# Move to the ready position while tilting, both at once.
	_kill_tween()
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(selected_drink_object, "position", target, move_time)
	tween.tween_property(selected_drink_object, "rotation_degrees", ready_rotation_deg, move_time)
	
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
	var returned_drink_enum := selected_drink_enum
	var drink_object := selected_drink_object
	
	# Clear selection immediately so game logic isn't waiting on the animation.
	selected_drink_enum = Drinks.NONE
	selected_drink_object = null
	
	if drink_object:
		busy = true
		var pos := home_position
		var rot := home_rotation_deg
		var z := home_z
		
		_kill_tween()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		
		# 1. Tip the drink into pouring position.
		tween.tween_property(drink_object, "rotation_degrees", pour_rotation_deg, tilt_time)
		# 2. Hold there for a moment (liquid animation will go here later).
		tween.tween_interval(pour_hold_time)
		# 3. Return home, moving and rotating at the same time.
		tween.tween_property(drink_object, "position", pos, move_time)
		tween.parallel().tween_property(drink_object, "rotation_degrees", rot, move_time)
		# 4. Restore draw order and unlock.
		tween.tween_callback(_on_drink_home.bind(drink_object, z))
	
	return returned_drink_enum


func cancel() -> void:
	var drink_object := selected_drink_object
	selected_drink_enum = Drinks.NONE
	selected_drink_object = null
	
	# reset_drink() in the main script calls this even with no selection, so guard.
	if drink_object == null:
		return
	
	busy = true
	var z := home_z
	
	_kill_tween()
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(drink_object, "position", home_position, move_time)
	tween.tween_property(drink_object, "rotation_degrees", home_rotation_deg, move_time)
	tween.chain().tween_callback(_on_drink_home.bind(drink_object, z))


## Makes the cup look full or empty. Called by the main script.
## Assumes frame 0 is the empty cup and frame 1 is the full cup.
func set_drink_sprite(is_full: bool) -> void:
	cup.frame = 1 if is_full else 0


func _on_drink_home(drink_object: Control, z: int) -> void:
	drink_object.z_index = z
	busy = false


func _kill_tween() -> void:
	if tween and tween.is_valid():
		tween.kill()
