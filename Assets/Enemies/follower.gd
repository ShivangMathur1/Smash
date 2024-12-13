extends CharacterBody2D

@export var EXPLOSION: PackedScene = preload("res://Assets/Particles/explosion.tscn")
@export var COIN: PackedScene = preload("res://Assets/Environment/coin.tscn")
@export var threshold = 8
@onready var health: Health = $Health
@onready var follow_cooldown: Timer = $FollowCooldown

const SPEED = 100.0

var follow_target: Player = null

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if follow_target != null:
		var displacement = follow_target.global_position.x - global_position.x
		if abs(displacement) > threshold:
			velocity.x = sign(displacement) * SPEED
	else:
		velocity.x = 0
	
	move_and_slide()

func _on_hurtbox_take_damage(attack: Attack) -> void:
	health.take_damage(attack)

func _on_health_death() -> void:
	queue_free()


func _on_player_detector_body_entered(body: Player) -> void:
	follow_cooldown.stop()
	follow_target = body


func _on_player_detector_body_exited(body: Player) -> void:
	follow_cooldown.start(1)


func _on_follow_cooldown_timeout() -> void:
	follow_target = null
