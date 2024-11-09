class_name Hitbox2D extends Area2D

@export var attack: Attack

signal hit(attack: Attack, collision_layer: int)

func _on_area_entered(hurtbox: Hurtbox2D) -> void:
	if hurtbox!= null:
		attack.direction = sign(hurtbox.global_position - global_position)
		hurtbox.hurt(attack)
		hit.emit(attack, hurtbox.collision_layer)
