class_name Inventory extends Node

signal collected

@export var inventory_items: Items = Items.new()
@export var collect_time = 1.0
@onready var collect_timer: Timer = $CollectTimer
var buffer: Items = Items.new()

func collect(items: Items):
	buffer.add(items)
	collect_timer.stop()
	collect_timer.start(collect_time)


func _on_collect_timer_timeout() -> void:
	inventory_items.add(buffer)
	buffer = Items.new()
	collected.emit()
