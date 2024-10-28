class_name Inventory extends Node

@export var inventory_items: Items = Items.new()

func collect(items: Items):
	inventory_items.add(items)
