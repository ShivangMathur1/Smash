class_name HUD extends CanvasLayer

@export var health_unit = preload("res://Assets/Menus/health_unit.tscn")

@onready var currency_label: Label = $Currency/CurrencyLabel
@onready var ammo_label: Label = $HealthAndAmmo/Ammo/AmmoLabel
@onready var health_container: HFlowContainer = $HealthAndAmmo/Health

var health_units: Array = []

var max_health: float:
	set(value):
		for child in health_container.get_children():
			child.queue_free()
		for i in range(value):
			var unit = health_unit.instantiate()
			health_units.append(unit)
			health_container.add_child(unit)
		max_health = value
	
var health: float = 0.0:
	set(value):
		for i in range(max_health):
			health_container.get_child(i).visible = i < value

var currency: int:
	set(value):
		currency_label.text = str(value)

var currency_buffer: int:
	set(value):
		currency_label.text = str(currency) + " + " + str(value)

var ammo: int:
	set(value):
		ammo = value
		ammo_label.text = str(value)
