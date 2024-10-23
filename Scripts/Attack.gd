class_name Attack extends Resource

@export var damage: float
@export var force: float

func _init(damage: float = 0.0, force: float  = 0.0) -> void:
	self.damage = damage
	self.force = force
