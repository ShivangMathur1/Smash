class_name Pickbox2D extends Area2D

@export var items: Item


func _on_body_entered(body: Player) -> void:
	body.collect(items)
	get_parent().queue_free()
