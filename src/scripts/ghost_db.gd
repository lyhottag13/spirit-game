extends Node

var pirate: Classes.Ghost = Classes.Ghost.new(
	"Patchy",
	"Arrr, I wants lots o' rum or I'll make ye walk the plank!\nTop it with something to remind me of the mighty, refreshing winds of the high seas!",
	"Dis drink be fearful, I'll throw ye in Davy Jones's locker!",
	"Dis drink be great, thanks matey.",
	preload("uid://c8pt4jstkgogc"),
	Classes.Drink.new(
		[
			Classes.DrinkType.RUM,
		],
		Classes.ToppingType.MINT,
	),
	
)

## Stores the randomized ghosts in an array for easy access using pick_random()
var random_ghosts: Array[Classes.Ghost] = [
	Classes.Ghost.new(
		"Vlad",
		"Give me vun, two, three pours of viskey. Ah-ah-ah!\nAnd give it my faaaavorite scarlet topping.",
		"I vill put your head on a stake for zhis!",
		"Zhis drink, my eternal deelight.",
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
		"A want tae remember ma college days, we are talkin parties, mixin liquors, an gettin intae trouble.\nA wis once pink like a cherry, afraid A wis gonna burst.",
		"Ye tryin tae be dreich wi me, ye'll have it!",
		"This is whit we're talkin aboot, thanks!",
		preload("uid://cibi7edi4hbmv"),
		Classes.Drink.new(
			[
			],
			Classes.ToppingType.CHERRY,
		),
	),
	Classes.Ghost.new(
		"Clint",
		"Ah want one awf 'em Kentucky Mules. Y'know, that soda-pop fizz with a bit o' sourness?\nGarnish it with something cool and refreshing.",
		"Ya vermin. Ah'm gonna jerk a knot in yo-wr tail!",
		"This is a blame daisy drank, thanks.",
		preload("uid://cfwce2nsr64jl"),
		Classes.Drink.new(
			[
				Classes.DrinkType.LIME,
				Classes.DrinkType.GINGER,
			],
			Classes.ToppingType.MINT,
		),
	),
	Classes.Ghost.new(
		"Calcifer",
		"I need a glass of sweet 'n sour for my weary bones.\nAnd I want something to chew on with my strong teeth!",
		"You've rattled with the wrong guy, pal.",
		"My bones are rattling with delight!",
		preload("uid://b0se56bn0t0ll"),
		Classes.Drink.new(
			[
				Classes.DrinkType.SYRUP,
				Classes.DrinkType.LIME,
			],
			Classes.ToppingType.EYEBALL,
		),
	),
]
