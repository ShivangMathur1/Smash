extends CharacterBody2D

@onready var health: Health = $Health
@export var EXPLOSION: PackedScene = preload("res://Scenes/Particles/explosion.tscn")

func _physics_process(delta: float) -> void:
	pass

func _on_hurtbox_take_damage(attack: Attack) -> void:
	health.take_damage(attack)

func _on_health_death() -> void:
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	add_sibling(explosion)
	queue_free()
