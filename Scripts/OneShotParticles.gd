extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true

func _on_finished():
	queue_free()
