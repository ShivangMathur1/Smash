class_name Attack extends Node

@export var damage: float
@export var force: float

func _init(damage: float, force: float) -> void:
	self.damage = damage
	self.force = force
