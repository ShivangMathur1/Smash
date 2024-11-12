extends CharacterBody2D

@onready var health: Health = $Health
@onready var follow_cooldown: Timer = $FollowCooldown

@export var EXPLOSION: PackedScene = preload("res://Scenes/Particles/explosion.tscn")
@export var speed = 100.0
@export var acceleration = 60.0

var follow_target: Player = null

func _physics_process(delta: float) -> void:
	if follow_target != null:
		var target_velocity = (follow_target.global_position - global_position).normalized() * speed
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.y = move_toward(velocity.y, target_velocity.y, acceleration * delta)
	else:
		velocity.x = 0
	
	move_and_slide()

func _on_hurtbox_take_damage(attack: Attack) -> void:
	health.take_damage(attack)

func _on_health_death() -> void:
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	add_sibling(explosion)
	queue_free()


func _on_player_detector_body_entered(body: Player) -> void:
	follow_cooldown.stop()
	follow_target = body


func _on_player_detector_body_exited(body: Player) -> void:
	follow_cooldown.start(1.0)


func _on_follow_cooldown_timeout() -> void:
	follow_target = null
