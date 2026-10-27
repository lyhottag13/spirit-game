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
	GIN,
	RUM,
	NONE, # Required as it's impossible to assign null to an enum-type var
}

var pirate: Dictionary[String, Variant] = {
	"movement_weight":75,
	"teleport_weight":20,
	"special_weight":5,
	"difficulty":0.2,
	"speed":300,
	"panic":0.3,
	"accel_mult":1,
	"scale":0.65,
	"movement_interval":1.5,
	"drink": {
		"base": [DrinkType.RUM, DrinkType.RUM, DrinkType.RUM],
		"topping": ToppingType.TOPPING1,
	},
	"order":"Ahoy. I wants lots o' rum or I'll scuttle ye, savvy?",
}

## Stores the randomized ghosts in an array for easy access using pick_random()
var random_ghosts: Array[Dictionary] = [
	{
		"name": "Bob",
		"order": "Vodka, rum, whiskey, and 1.",
		"drink": {
			"base": ["vodka", "rum", "whiskey"],
			"topping": ToppingType.TOPPING1,
		},
	},
	{
		"name": "Julie",
		"order": "Vodka all the way and 1.",
		"drink": {
			"base": ["vodka", "vodka", "vodka"],
			"topping": ToppingType.TOPPING1,
		},
	},
	{
		"name": "Crazy Carl",
		"order": "Ginger, ginger, rum, and 1.",
		"drink": {
			"base": ["ginger", "ginger", "rum"],
			"topping": ToppingType.TOPPING1,
		},
	},
]
