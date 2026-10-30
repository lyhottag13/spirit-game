extends Node

var pirate: Classes.Ghost = Classes.Ghost.new(
	"Patchy",
	"Ahoy. I wants lots o' rum or I'll scuttle ye, savvy?",
	"im fuming",
	"i fw it",
	preload("uid://c8pt4jstkgogc"),
	Classes.Drink.new(
		[
			Classes.DrinkType.RUM,
			Classes.DrinkType.RUM,
			Classes.DrinkType.RUM,
		],
		Classes.ToppingType.MINT,
	),
	
)

## Stores the randomized ghosts in an array for easy access using pick_random()
var random_ghosts: Array[Classes.Ghost] = [
	Classes.Ghost.new(
		"Vlad",
		"Give me one, two, three pours of whiskey. Ah-ah-ah!\nAnd don't forget to give it my faaaavorite scarlet topping.",
		"im fuming",
		"i fw it",
		preload("uid://bvh4q06xxcxv5"),
		Classes.Drink.new(
			[
				Classes.DrinkType.WHISKEY,
				Classes.DrinkType.WHISKEY,
				Classes.DrinkType.WHISKEY,
			],
			Classes.ToppingType.BLOOD,
		),
	),
	Classes.Ghost.new(
		"Glarie",
		"I don't see myself liking your drink unless... Vodka.\nAnd blah blah blah.",
		"im fuming",
		"i fw it",
		preload("uid://cibi7edi4hbmv"),
		Classes.Drink.new(
			[
				Classes.DrinkType.VODKA,
				Classes.DrinkType.VODKA,
				Classes.DrinkType.VODKA,
			],
			Classes.ToppingType.MINT,
		),
	),
	Classes.Ghost.new(
		"Crazy Carl",
		"Ginger, ginger, rum, and 1.",
		"im fuming",
		"i fw it",
		preload("uid://c8pt4jstkgogc"),
		Classes.Drink.new(
			[
				Classes.DrinkType.GINGER,
				Classes.DrinkType.GINGER,
				Classes.DrinkType.RUM,
			],
			Classes.ToppingType.MINT,
		),
	),
	Classes.Ghost.new(
		"Elmer",
		"Give me all syrup. I love syrup.\nAnd mint, too.",
		"im fuming",
		"i fw it",
		preload("uid://c8pt4jstkgogc"),
		Classes.Drink.new(
			[
				Classes.DrinkType.SYRUP,
				Classes.DrinkType.SYRUP,
				Classes.DrinkType.SYRUP,
			],
			Classes.ToppingType.MINT,
		),
	),
]
