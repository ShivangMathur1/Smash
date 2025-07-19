extends Node2D

@onready var selection_wheel: SelectionWheel = $Menus/GameMenu/SelectionWheel
@onready var levels: Node = $Levels

func _ready() -> void:
	
	selection_wheel.options = [
		WheelOptions.new("Resume", "Continue to your game"),
		WheelOptions.new("Options", "Change settings and keybinds"),
		WheelOptions.new("Save and exit", "Save the game and go to main menu"),
		WheelOptions.new("Save and quit", "Save game and quit to desktop"),
		]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not selection_wheel.is_visible_in_tree():
			selection_wheel.show()
			get_tree().paused = true


func _on_selection_wheel_item_selected(selected_option: int) -> void:
	if selected_option == 0:
		selection_wheel.hide()
		get_tree().paused = false
	elif selected_option == 1:
		selection_wheel.hide()
		get_tree().paused = false
	elif selected_option == 2:
		selection_wheel.hide()
		get_tree().paused = false
	elif selected_option == 3:
		get_tree().quit()
