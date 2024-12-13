class_name Pickbox2D extends Area2D

@export var items: Items
@export var pickable_time = 0.2
@onready var pickable_timer: Timer = $PickableTimer

func _ready() -> void:
	pickable_timer.start(pickable_time)

func _on_body_entered(body: Player) -> void:
	body.collect(items)
	get_parent().queue_free()


func _on_pickable_timer_timeout() -> void:
	set_deferred("monitoring", "true")
