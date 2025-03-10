@tool
class_name SelectionWheel extends Control

@export var options: Array[WheelOptions]

@export_group("Colors")
@export var background_color: Color = Color("262626")
@export var line_color: Color = Color("151515")
@export var highlight_color: Color = Color("535353")

@export_group("Sizing")
@export var outer_radius: float = 256
@export var inner_radius: float = 96
@export var mouse_dropoff_radius: float = 300
@export var line_width: float = 4
@export var offset_angle: float = 0


signal item_selected(selected_option: int)
signal item_hovered(selected_option: int)

var font: Font = SystemFont.new()
var selected_option: int
var center: Vector2

func _ready() -> void:
	selected_option = -1

func _draw() -> void:
	# Draw the circles
	draw_circle(Vector2.ZERO, outer_radius, background_color, true)
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)
	
	# Draw the lines
	if len(options) > 1:
		for i in range(len(options)):
			var angle = deg_to_rad(offset_angle) +  TAU * i / len(options)
			var unit_vector = Vector2.from_angle(angle)
			draw_line(
				inner_radius * unit_vector,
				outer_radius * unit_vector,
				line_color,
				line_width, 
				true
			)
			
	 #Center text
	if selected_option >= 0 and options and options[selected_option]:
		draw_multiline_string(
			font,
			Vector2(-inner_radius * 0.75, 0),
			options[selected_option].description,
			HORIZONTAL_ALIGNMENT_CENTER,
			inner_radius * 1.5
		)
	
	# Draw option text
	for i in range(len(options)):
		if options[i] != null:
			var mid_angle = i * TAU / len(options) + TAU / (2 * len(options)) + deg_to_rad(offset_angle)
			var mid_radius = (inner_radius + outer_radius) / 2
			var offset = font.get_string_size(options[i].name).x
			
			if selected_option == i:
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				
				var start_rads = (TAU * i) / (len(options))
				var end_rads = (TAU * (i + 1)) / (len(options))
				
				for j in range(points_per_arc + 1):
					var angle = start_rads + deg_to_rad(offset_angle) + j * (end_rads - start_rads) / points_per_arc
					points_inner.append(inner_radius * Vector2.from_angle(angle))
					points_outer.append(outer_radius * Vector2.from_angle(angle))
				
				points_outer.reverse()
				draw_polygon(
					points_inner + points_outer,
					PackedColorArray([highlight_color])
				)
			
			var drawpos = mid_radius * Vector2.from_angle(mid_angle) - Vector2(offset / 2, 0)
			draw_string(font, drawpos, options[i].name, HORIZONTAL_ALIGNMENT_CENTER)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_position = get_local_mouse_position()
		
		if mouse_position.length() < mouse_dropoff_radius:
			var mouse_rads = fposmod(mouse_position.angle() - deg_to_rad(offset_angle), TAU)
			selected_option = floor(mouse_rads / TAU * len(options))
			item_hovered.emit(selected_option)
		else:
			selected_option = -1
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				item_selected.emit(selected_option)
	
	queue_redraw()
