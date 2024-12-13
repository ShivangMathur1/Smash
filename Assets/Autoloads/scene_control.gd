extends Node

@onready var world: Node2D = $World
@onready var gui: Control = $GUI

const MAIN_MENU = preload("res://Assets/Menus/main_menu.tscn")

var current_scene: Node = null

func _ready() -> void:
	gui.add_child(MAIN_MENU.instantiate())

func change_scene(scene: PackedScene):
	_deferred_change_scene.call_deferred(scene)

func _deferred_change_scene(scene: PackedScene):
	if current_scene:
		current_scene.free()
	
	current_scene = scene.instantiate()
	world.add_child(current_scene)
