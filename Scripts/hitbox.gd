extends Area2D

class_name Hitbox2D

signal take_damage(attack: Attack)

func hit(attack: Attack):
	take_damage.emit(attack)
