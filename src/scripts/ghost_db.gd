extends Node

var pirate: Classes.Ghost = Classes.Ghost.new(
	"Davey",
	"Ahoy. I wants lots o' rum or I'll scuttle ye, savvy?",
	preload("uid://c8pt4jstkgogc"),
	Classes.Drink.new(
		[
			Classes.DrinkType.RUM,
			Classes.DrinkType.RUM,
			Classes.DrinkType.RUM,
		],
		Classes.ToppingType.TOPPING1,
	),
)

## Stores the randomized ghosts in an array for easy access using pick_random()
var random_ghosts: Array[Classes.Ghost] = [
	Classes.Ghost.new(
		"Bob",
		"Vodka, rum, whiskey, and 1.",
		preload("uid://c8pt4jstkgogc"),
		Classes.Drink.new(
			[
				Classes.DrinkType.VODKA,
				Classes.DrinkType.RUM,
				Classes.DrinkType.WHISKEY,
			],
			Classes.ToppingType.TOPPING1,
		),
	),
	Classes.Ghost.new(
		"Julie",
		"Vodka all the way and 1.",
		preload("uid://c8pt4jstkgogc"),
		Classes.Drink.new(
			[
				Classes.DrinkType.VODKA,
				Classes.DrinkType.VODKA,
				Classes.DrinkType.VODKA,
			],
			Classes.ToppingType.TOPPING1,
		),
	),
	Classes.Ghost.new(
		"Crazy Carl",
		"Ginger, ginger, rum, and 1.",
		preload("uid://c8pt4jstkgogc"),
		Classes.Drink.new(
			[
				Classes.DrinkType.GINGER,
				Classes.DrinkType.GINGER,
				Classes.DrinkType.RUM,
			],
			Classes.ToppingType.TOPPING1,
		),
	),
]
