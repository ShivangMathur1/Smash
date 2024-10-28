extends Node2D
@export var items: Item

const COIN = preload("res://Scenes/coin.tscn")

func _exit_tree() -> void:
	for i in items.currency:
		get_tree().root.add_child(spawn(COIN))

func spawn(resource: PackedScene):
	var res: RigidBody2D = resource.instantiate()
	res.global_position = global_position
	res.linear_velocity = Vector2(randf_range(-200, 200), -300)
	return res
