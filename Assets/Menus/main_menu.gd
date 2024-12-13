extends CanvasLayer

@export var level0: PackedScene
@onready var texture_rect: TextureRect = $TextureRect

@export var noise: FastNoiseLite
@export var speed: float = 10

func _ready() -> void:
	noise.seed = randi() % 10
	texture_rect.texture.noise = noise

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	noise.offset.x += speed * delta
	noise.offset.y += speed * delta


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(level0)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
