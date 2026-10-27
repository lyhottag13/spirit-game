extends Node

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
	BLOOD,
	WHISKEY,
	GINGER,
	RUM,
	NONE, # Required as it's impossible to assign null to an enum-type var
}

## Custom data type to hold drink information.
class Drink:
	## Stores the drink's base, should only go up to three.
	var base: Array
	
	## Stores the drink's current topping. There's only one.
	var topping: ToppingType
	
	func _init(
		p_base: Array = [],
		p_topping: ToppingType = ToppingType.NONE,
	) -> void:
		base = p_base
		topping = p_topping

class Ghost:
	var name: String
	var order: String
	var texture: CompressedTexture2D
	var drink: Drink
	
	func _init(
		p_name: String = "Default", 
		p_order: String = "Default", 
		p_texture: CompressedTexture2D = preload("uid://c8pt4jstkgogc"),
		p_drink: Drink = Drink.new(),
		) -> void:
			name = p_name
			order = p_order
			texture = p_texture
			drink = p_drink
