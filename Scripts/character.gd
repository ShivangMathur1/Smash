extends CharacterBody2D

const BULLET = preload("res://Scenes/bullet.tscn")
const SPARKS = preload("res://Scenes/Sparks.tscn")
const DASH_CLOUD = preload("res://Scenes/dash_cloud.tscn")

@onready var shoot_timer = $ShootTimer
@onready var dash_timer = $DashTimer
@onready var label = $CanvasLayer/Label

const SPEED = 200.0
const JUMP_VELOCITY = -500.0
const DASH_SPEED = 600
const WALL_JUMP_VELOCITY = Vector2(200, -400)
const WALL_SLIDE_VELOCITY = 100
const TERMINAL_VELOCITY = Vector2(800, 800)
const AMMO_CAPACITY = 12

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var horizontal_control = 1
var can_shoot = true
var can_dash = true
var ammo

var facing = 1.0

func _ready():
	ammo = AMMO_CAPACITY
	label.text = str(ammo)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += air_gravity_values() * gravity * delta
		if velocity.y > WALL_SLIDE_VELOCITY and is_on_wall():
			velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCITY, 100)
		

	# Handle jump and wall jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			play_particle(SPARKS, Vector2(0, 1))
		elif is_on_wall():
			velocity = WALL_JUMP_VELOCITY
			velocity.x *= get_wall_normal().x
			horizontal_control = 0
			play_particle(SPARKS, Vector2(1, -get_wall_normal().x).normalized())


	# Handle variable jump height (early release)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y /= 4
		horizontal_control = 1


	# Get the input direction
	var direction = Input.get_axis("left", "right")
	facing = direction if direction != 0 else facing
	if is_on_wall() and not is_on_floor():
		facing = get_wall_normal().x
	
	# Handle dashing
	if Input.is_action_just_pressed("dash") and can_dash:
		velocity.x = DASH_SPEED * facing
		velocity.y = 0
		horizontal_control = 0
		can_dash = false
		dash_timer.start(0.2)
		play_particle(DASH_CLOUD, Vector2(-facing, 0))
	
	# Handle the movement/deceleration.
	if horizontal_control == 1:
		if not Input.is_action_pressed("lock") and direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# TODO add lerp to horizontal controls as well
	horizontal_control = move_toward(horizontal_control, 1, 0.08)
	
	# Limit max velocity forever
	velocity = velocity.clamp(-TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	
	
	# Handle attack inputs
	if Input.is_action_pressed("shoot") and can_shoot:
		var x = BULLET.instantiate()
		x.global_position = global_position
		var pointing = Input.get_vector("left", "right", "up", "down")
		if pointing == Vector2.ZERO or is_on_wall() or horizontal_control != 1:
			x.global_rotation = (Vector2.RIGHT * facing).angle()
		else:
			x.global_rotation = pointing.angle()
		add_sibling(x)
		ammo -= 1
		can_shoot = false
		if ammo <= 0:
			shoot_timer.start(2)
			label.text = "reloading..."
		else:
			shoot_timer.start(0.1)
			label.text = str(ammo)

	move_and_slide()

# Handle slow rise, hang time and fast descend for jumps
func air_gravity_values():
	if velocity.y < -30:
		return 1
	elif velocity.y < 30:
		return 0.4
	else:
		return 3

func play_particle(particle, direction):
	var instance = particle.instantiate()
	instance.direction = direction
	add_child(instance)

func _on_shoot_timer_timeout():
	can_shoot = true
	if ammo <= 0:
		ammo = AMMO_CAPACITY
		label.text = str(ammo)


func _on_dash_timer_timeout():
	can_dash = true
