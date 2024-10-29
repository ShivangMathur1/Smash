class_name Player extends CharacterBody2D

@export var BULLET: PackedScene = preload("res://Scenes/character_bullet.tscn")
@export var SPARKS: PackedScene = preload("res://Scenes/Particles/sparks.tscn")
@export var DASH_CLOUD: PackedScene = preload("res://Scenes/Particles/dash_cloud.tscn")

@onready var shoot_timer = $ShootTimer
@onready var dash_timer = $DashTimer
@onready var horizontal_control_timer: Timer = $HorizontalControlTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var ammo_label = $CanvasLayer/AmmoLabel
@onready var currency_label: Label = $CanvasLayer/CurrencyLabel
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox2D = $Hurtbox
@onready var inventory: Inventory = $Inventory

const SPEED = 200.0
const JUMP_VELOCITY = -500.0
const DASH_SPEED = 600
const WALL_JUMP_VELOCITY = Vector2(200, -400)
const WALL_SLIDE_VELOCITY = 100
const TERMINAL_VELOCITY = Vector2(800, 800)
const AMMO_CAPACITY = 12

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var horizontal_control = true
var can_shoot = true
var can_dash = Enums.dash_states.cannot_dash
var can_wall_jump = false
var ammo

var facing = 1.0

func _ready():
	ammo = AMMO_CAPACITY
	ammo_label.text = str(ammo)
	currency_label.text = "0"

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += air_gravity_values() * gravity * delta
		
		# Perform a wall sLide
		if can_wall_jump and is_on_wall() and velocity.y > WALL_SLIDE_VELOCITY:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCITY, 100)
		if can_dash == Enums.dash_states.dashing:
			velocity.y = 0


	# Handle jump and wall jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			play_particle(SPARKS, Vector2(0, 1))
		elif is_on_wall() and can_wall_jump:
			velocity = WALL_JUMP_VELOCITY
			velocity.x *= get_wall_normal().x
			horizontal_control = false
			horizontal_control_timer.start(0.2)
			play_particle(SPARKS, Vector2(1, -get_wall_normal().x).normalized())


	# Handle variable jump height (early release)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y /= 4
		horizontal_control = true


	# Get the input direction
	var direction = Input.get_axis("left", "right")
	facing = direction if direction != 0 else facing
	if can_wall_jump and is_on_wall() and not is_on_floor():
		facing = get_wall_normal().x
	
	# Handle dashing
	if Input.is_action_just_pressed("dash") and can_dash == Enums.dash_states.can_dash:
		velocity.x = DASH_SPEED * facing
		velocity.y = 0
		horizontal_control = false
		horizontal_control_timer.start(0.1)
		can_dash = Enums.dash_states.dashing
		dash_timer.start(0.4)
		play_particle(DASH_CLOUD, Vector2(-facing, 0))
	
	# Reset dash if wall jumped or jumped
	if is_on_floor() or (can_wall_jump and is_on_wall()):
		if can_dash == Enums.dash_states.has_dashed:
			can_dash = Enums.dash_states.can_dash
	
	# Stop dashing if hit wall
	if is_on_wall() and can_dash == Enums.dash_states.dashing:
		can_dash = Enums.dash_states.has_dashed
	
	
	# Handle the movement/deceleration.
	if horizontal_control == true:
		if not Input.is_action_pressed("lock") and direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	# Limit max velocity forever
	velocity = velocity.clamp(-TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	
	
	# Handle attack inputs
	if Input.is_action_pressed("shoot") and can_shoot:
		var x = BULLET.instantiate()
		x.global_position = global_position
		var pointing = Input.get_vector("left", "right", "up", "down")
		
		# Handle bullet direction in case not specified (or unable to be specified) by player
		if pointing == Vector2.ZERO or is_on_wall() or horizontal_control != true:
			x.global_rotation = (Vector2.RIGHT * facing).angle()
		else:
			x.global_rotation = pointing.angle()
		add_sibling(x)
		ammo -= 1
		can_shoot = false
		if ammo <= 0:
			shoot_timer.start(2)
			ammo_label.text = "reloading..."
		else:
			shoot_timer.start(0.1)
			ammo_label.text = str(ammo)
	
	move_and_slide()

# Handle slow rise, hang time and fast descend for jumps
func air_gravity_values():
	if velocity.y < -50:
		return 1
	elif velocity.y < -10:
		return 0.4
	else:
		return 3

func play_particle(particle, direction):
	var instance = particle.instantiate()
	instance.direction = direction
	add_child(instance)

func collect(items: Items):
	inventory.collect(items)
	if items.health > 0:
		health.heal(items.health)
	currency_label.text = str(inventory.inventory_items.currency)

# Reload
func _on_shoot_timer_timeout():
	can_shoot = true
	if ammo <= 0:
		ammo = AMMO_CAPACITY
		ammo_label.text = str(ammo)

func _on_dash_timer_timeout():
	if can_dash == Enums.dash_states.dashing:
		can_dash = Enums.dash_states.has_dashed

func _on_horizontal_control_timer_timeout() -> void:
	horizontal_control = true

func _on_health_death() -> void:
	print("dead")

func _on_hurtbox_take_damage(attack: Attack) -> void:
	health.take_damage(attack)
	velocity = attack.direction * attack.force
	hurtbox.set_deferred("monitorable", false)
	invincibility_timer.start(1.5)
	horizontal_control = false
	horizontal_control_timer.start(0.4)


# Coyote time
# bullet spark direction
# Jump buffering
# Handle can dash can jump with animations

func _on_invincibility_timer_timeout() -> void:
	hurtbox.set_deferred("monitorable", true) 
