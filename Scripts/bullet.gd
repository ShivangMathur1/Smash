extends Area2D

@onready var death_timer = $DeathTimer

var velocity: Vector2

const SPARKS = preload("res://Scenes/Sparks.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var sparks = SPARKS.instantiate()
	sparks.direction = -sparks.direction
	add_child(sparks)
	velocity = Vector2(1000, 0).rotated(rotation)
	death_timer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta

func _on_death_timer_timeout():
	queue_free()

func _on_area_2d_body_entered():
	queue_free()
