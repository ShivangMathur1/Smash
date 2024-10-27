extends Sprite2D
@export var EXPLOSION: PackedScene = preload("res://Scenes/Particles/explosion.tscn")
@onready var hurtbox_2d: Hurtbox2D = $Hurtbox2D

@export var live_frame: int
@export var remove_on_death: bool
@export var death_frame: int

func _ready() -> void:
	frame = live_frame

func _on_hurtbox_2d_take_damage(attack: Attack) -> void:
	var explosion = EXPLOSION.instantiate()
	explosion.position = global_position
	add_sibling(explosion)
	hurtbox_2d.queue_free()
	if remove_on_death:
		queue_free()
	else:
		frame = death_frame
