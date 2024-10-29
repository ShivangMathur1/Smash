extends Sprite2D

@export var hits = 4
const COIN = preload("res://Scenes/coin.tscn")

func _on_hurtbox_take_damage(attack: Attack) -> void:
	hits -= 1
	for i in range(3):
		add_sibling(spawn(COIN))
	
	if hits <= 0:
		queue_free()


func spawn(resource: PackedScene):
	var res: RigidBody2D = resource.instantiate()
	res.global_position = global_position
	res.linear_velocity = Vector2(randf_range(-200, 200), -300)
	return res
