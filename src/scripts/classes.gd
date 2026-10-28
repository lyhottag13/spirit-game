extends Node

enum ToppingType {
	MINT,
	CHERRY,
	EYEBALL,
	BLOOD,
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
	var fight_mode_data: FightModeData
	
	func _init(
		p_name: String = "Default", 
		p_order: String = "Default", 
		p_texture: CompressedTexture2D = preload("uid://c8pt4jstkgogc"),
		p_drink: Drink = Drink.new(),
		p_fight_mode_data: FightModeData = FightModeData.new(),
		) -> void:
			name = p_name
			order = p_order
			texture = p_texture
			drink = p_drink
			fight_mode_data = p_fight_mode_data


class FightModeData:
	var movement_weight
	var teleport_weight
	var special_weight
	var difficulty
	var speed
	var panic
	var accel_mult
	var scale
	var movement_interval


	func _init(
		p_movement_weight: float = 75,
		p_teleport_weight: float = 20,
		p_special_weight: float = 5,
		p_difficulty: float = 0.2,
		p_speed: float = 300,
		p_panic: float = 0.3,
		p_accel_mult: float = 1,
		p_scale: float = 0.65,
		p_movement_interval: float = 1.5
	) -> void:
		movement_weight = p_movement_weight
		teleport_weight = p_teleport_weight
		special_weight = p_special_weight
		difficulty = p_difficulty
		speed = p_speed
		panic = p_panic
		accel_mult = p_accel_mult
		scale = p_scale
		movement_interval = p_movement_interval
		
