extends Camera2D

@export var character: CharacterBody2D
@export var lookahead: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = character.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = character.position.x + character.velocity.normalized().x * lookahead
	position.y = character.position.y
