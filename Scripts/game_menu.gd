class_name GameMenu extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("pause"):
		#print("escaped!")
		#get_tree().paused = !get_tree().paused
		#visible = !visible


func _on_continue_button_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
