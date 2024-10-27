extends CharacterBody2D

@onready var health: Health = $Health
@onready var edge_detector: RayCast2D = $EdgeDetector

@export var SPEED = 50.0
@export var EXPLOSION: PackedScene = preload("res://Scenes/Particles/explosion.tscn")

var direction = 1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_wall() or (is_on_floor() and edge_detector.is_colliding() == false):
		direction = -direction
	velocity.x = direction * SPEED

	move_and_slide()


func _on_hurtbox_take_damage(attack: Attack) -> void:
	health.take_damage(attack)


func _on_health_death() -> void:
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	add_sibling(explosion)
	queue_free()
