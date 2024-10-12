extends CharacterBody2D

@onready var death_timer = $DeathTimer
@export var BULLET_SPEED = 800
const SPARKS = preload("res://Scenes/Sparks.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var sparks = SPARKS.instantiate()
	sparks.direction = Vector2(1, 0).rotated(rotation)
	sparks.position = global_position
	add_sibling(sparks)
	velocity = sparks.direction * BULLET_SPEED
	death_timer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var object = move_and_collide(velocity * delta)
	if object != null:
		var sparks = SPARKS.instantiate()
		sparks.direction = object.get_normal()
		sparks.position = global_position
		add_sibling(sparks)
		queue_free()

func _on_death_timer_timeout():
	queue_free()

func _on_hurtbox_hit() -> void:
	queue_free()
