class_name WheelOptions extends Resource

@export var name: String
@export var description: String

func _init(name = "", description = "") -> void:
	self.name = name
	self.description = description
