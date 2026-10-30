class_name Bar
extends Node2D

const GHOST_Y_POSITION = 510

var ghost_tween: Tween

## Stores the ghost texture to be displayed. Defaults to Pirate.
var ghost_texture: CompressedTexture2D = preload("uid://c8pt4jstkgogc")

## Stores a reference to the cup if we've swapped from the topping scene.
var cup

@onready var ghost: Sprite2D = %Ghost

func _ready() -> void:
	# Sets the displayed ghost's texture to the variable above.
	ghost.texture = ghost_texture
	
	# Starts the ghost hover tween loop.
	loop_tween()


func loop_tween() -> void:
	const HOVER_TIME = 1
	ghost_tween = create_tween().set_loops()
	ghost_tween.tween_property(ghost, "position:y", GHOST_Y_POSITION + 20, HOVER_TIME).set_trans(Tween.TRANS_SINE)
	ghost_tween.tween_property(ghost, "position:y", GHOST_Y_POSITION - 20, HOVER_TIME).set_trans(Tween.TRANS_SINE)


func react_to_drink(good_reaction: bool):
	if not good_reaction:
		var angry_tween: Tween = create_tween().set_loops(3).set_trans(Tween.TRANS_SINE)
		angry_tween.tween_property(ghost, "position:x", ghost.position.x + 20, 0.2)
		angry_tween.tween_property(ghost, "position:x", ghost.position.x - 20, 0.2)
		await angry_tween.finished
		
		# Resets the ghost back to their original position.
		await create_tween().set_trans(Tween.TRANS_SINE).tween_property(ghost, "position:x", ghost.position.x + 20, 0.2).finished
	
	else:
		var happy_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		happy_tween.tween_property(ghost, "offset:y", ghost.offset.y + 20, 0.2)
		happy_tween.tween_property(ghost, "offset:y", ghost.offset.y - 20, 0.2)
		happy_tween.tween_property(ghost, "offset:y", ghost.offset.y + 20, 0.2)
		await happy_tween.finished
	
	# Lets the player stew in their drink-making choices for a bit.
	await get_tree().create_timer(1).timeout

## Moves the old customer out and the new customer in.
func swap_customer(new_customer_texture: CompressedTexture2D) -> void:
	await exit_ghost()
	
	# Assigns the new texture to the ghost object.
	ghost.texture = new_customer_texture
	
	# Teleports the ghost sprite to the right side of the screen.
	ghost.position.x = DisplayServer.window_get_size().x + 600
	
	await enter_ghost()


func exit_ghost() -> void:
	await create_tween().tween_property(ghost, "position:x", -600, 3).set_trans(Tween.TRANS_QUAD).finished


func set_ghost_texture(p_ghost_texture: CompressedTexture2D) -> void:
	ghost_texture = p_ghost_texture


func place_cup(cup_node: Node2D) -> void:
	cup = cup_node
	
	add_child(cup_node)
	
	# Moves the cup node behind the peanuts.
	move_child(cup, -2)
	
	# Places the cup in front of the customer at an adequate scale.
	cup_node.position = Vector2(946, 813)
	cup_node.scale = Vector2(0.4, 0.4)


## Moves the drink to the left. Has a *chance* of failing if cup doesn't exist,
## but Main Game calls this method after a serve, during which a cup always exists
## on screen.
func exit_cup() -> void:
	if cup:
		await create_tween().tween_property(cup, "position:x", -300 , 3).set_trans(Tween.TRANS_QUAD).finished
		cup.queue_free()


func enter_ghost() -> void:
	# Moves the ghost texture back to the center with the new texture.
	await create_tween().tween_property(ghost, "position:x", 960, 3).set_trans(Tween.TRANS_QUAD).finished
