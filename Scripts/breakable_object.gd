extends StaticBody2D
@export var EXPLOSION: PackedScene = preload("res://Scenes/Particles/explosion.tscn")

func _on_hurtbox_take_damage(attack: Attack) -> void:
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	add_sibling(explosion)
	queue_free()
