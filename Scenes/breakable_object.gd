extends StaticBody2D
const EXPLOSION = preload("res://Scenes/explosion.tscn")


func _on_hitbox_take_damage(attack: Attack) -> void:
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	add_sibling(explosion)
	queue_free()
