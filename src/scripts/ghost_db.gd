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

var ghosts = {
	"pirate": {
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
	},
	"2": {
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
			"base": ["vodka", "rum", "whiskey"],
			"topping": ToppingType.TOPPING1
		}
	},
	"3": {
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
			"base": ["vodka", "vodka", "vodka"],
			"topping": ToppingType.TOPPING1
		}
	},
	"4": {
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
			"base": ["ginger", "ginger", "rum"],
			"topping": ToppingType.TOPPING1
		}
	},
}
