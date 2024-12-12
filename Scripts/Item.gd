class_name Items extends Resource

@export var currency: int
@export var health: float

func _init(currency: int = 0, health: float = 0.0) -> void:
	self.currency = currency
	self.health = health

func add(items: Items):
	self.currency += items.currency

func subtract(items: Items):
	self.currency -= items.currency
