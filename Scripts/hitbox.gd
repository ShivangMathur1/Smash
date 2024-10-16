class_name Hitbox2D extends Area2D

@export var damage: float
@export var force: float

signal hit

func _on_area_entered(hurtbox: Hurtbox2D) -> void:
	if hurtbox!= null:
		hurtbox.hurt(Attack.new(damage, force))
		hit.emit()
