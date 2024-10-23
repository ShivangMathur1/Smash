class_name Hitbox2D extends Area2D

@export var attack: Attack

signal hit

func _on_area_entered(hurtbox: Hurtbox2D) -> void:
	if hurtbox!= null:
		hurtbox.hurt(attack)
		hit.emit()
