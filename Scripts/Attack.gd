class_name Attack extends Resource

@export var damage: float
@export var force: float
var direction: Vector2 = Vector2.RIGHT

func _init(damage = 0.0, force = 0.0, direction = Vector2.RIGHT) -> void:
	self.damage = damage
	self.force = force
	self.direction = direction
