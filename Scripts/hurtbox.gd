class_name Hurtbox2D extends Area2D


signal take_damage(attack: Attack)

func hurt(attack: Attack):
	take_damage.emit(attack)
