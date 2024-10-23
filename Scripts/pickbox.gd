class_name Pickbox2D extends Area2D
@export var items: Item


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.collect(items)
		queue_free()
