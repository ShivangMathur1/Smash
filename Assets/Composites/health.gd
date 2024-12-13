class_name Health extends Node2D

signal damage_taken(current_health, damage_taken)
signal damage_healed(current_health, damage_healed)
signal death

@export var maxHealth = 10

var health

func _ready() -> void:
	health = maxHealth
	
func take_damage(attack: Attack):
	health = max(health - attack.damage, 0)
	damage_taken.emit(health, attack.damage)
	if health == 0:
		death.emit()

func heal(amount):
	health = min(health + amount, maxHealth)
	damage_healed.emit(health, amount)