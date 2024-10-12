class_name  Hurtbox2D extends Area2D

@export var damage: float
@export var force: float

signal hit

func _on_area_entered(area: Area2D) -> void:
	var hitbox: Hitbox2D = area
	hitbox.hit(Attack.new(damage, force))
	hit.emit()
