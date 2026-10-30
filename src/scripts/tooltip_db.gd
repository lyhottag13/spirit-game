extends Node

var drink_database: Dictionary[Classes.DrinkType, Classes.ItemInfo] = {
	Classes.DrinkType.VODKA: Classes.ItemInfo.new("Vodka", "Neutral Flavor\nPairs well with anything"),
	Classes.DrinkType.SYRUP: Classes.ItemInfo.new("Syrup", "Sweet\nLight Flavor"),
	Classes.DrinkType.LIME: Classes.ItemInfo.new("Lime", "Tart\nBitter\nAcidic Flavor"),
	Classes.DrinkType.WHISKEY: Classes.ItemInfo.new("Whiskey", "Smokey\nCrisp Flavor\nPairs well with soda"),
	Classes.DrinkType.GINGER: Classes.ItemInfo.new("Ginger", "Fizzy\nSharp Flavor\nKey component in mule"),
	Classes.DrinkType.RUM: Classes.ItemInfo.new("Rum", "Oaky\nSpiced Flavor\nPairs well with juice"),
}

var topping_database: Dictionary[Classes.ToppingType, Classes.ItemInfo] = {
	Classes.ToppingType.MINT: Classes.ItemInfo.new("Mint", "Strong\nCool Flavor"),
	Classes.ToppingType.CHERRY: Classes.ItemInfo.new("Cherry", "Luxurious\nRich Flavor"),
	Classes.ToppingType.EYEBALL: Classes.ItemInfo.new("Eyeball", "Chewy\nDull Flavor"),
	Classes.ToppingType.BLOOD: Classes.ItemInfo.new("Blood", "Bitter\nMetallic Flavor"),
}
