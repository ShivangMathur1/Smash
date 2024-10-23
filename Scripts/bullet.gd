extends CharacterBody2D

@onready var death_timer = $DeathTimer
@onready var hitbox: Hitbox2D = $Hitbox

@export var BULLET_SPEED = 800
@export var BULLET_ATTACK: Attack = Attack.new(1, 0)
@export var SPARKS: PackedScene = preload("res://Scenes/Particles/Sparks.tscn")

var direction = Vector2.RIGHT

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)
	velocity = direction * BULLET_SPEED
	hitbox.attack = BULLET_ATTACK
	
	spawn_sparks(direction)
	death_timer.start()
	
func _process(delta):
	var object = move_and_collide(velocity * delta)
	if object != null:
		spawn_sparks(-direction)
		queue_free()

func spawn_sparks(direction: Vector2):
	var sparks: CPUParticles2D = SPARKS.instantiate()
	sparks.direction = direction
	sparks.position = global_position
	add_sibling(sparks)

func _on_death_timer_timeout():
	queue_free()

func _on_hitbox_hit() -> void:
	spawn_sparks(-direction)
	queue_free()
