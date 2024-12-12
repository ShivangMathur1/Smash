class_name Player extends CharacterBody2D


@export var SPEED = 200.0
@export var TERMINAL_VELOCITY = Vector2(800, 800)
@export var hit_invincibility_time = 1.5
@export var hit_control_loss_time = 0.2

@export_group("Jumping")
@export var jump_state = Enums.jump_states.cannot_jump
@export var SPARKS: PackedScene = preload("res://Scenes/Particles/sparks.tscn")
@export var JUMP_VELOCITY = -500.0
@export var coyote_time = 0.05

@export_group("Wall Jumping")
@export var wall_jump_enabled = false
@export var WALL_JUMP_VELOCITY = Vector2(200, -400)
@export var WALL_SLIDE_VELOCITY = 100
@export var wall_jump_control_loss_time = 0.2

@export_group("Dashing")
@export var dash_state = Enums.dash_states.cannot_dash
@export var DASH_CLOUD: PackedScene = preload("res://Scenes/Particles/dash_cloud.tscn")
@export var DASH_SPEED = 600
@export var dash_time = 0.4
@export var dash_control_loss_time = 0.1

@export_group("Shooting")
@export var shooting_enabled = true
@export var BULLET: PackedScene = preload("res://Scenes/character_bullet.tscn")
@export var AMMO_CAPACITY = 12
@export var shoot_time = 0.1
@export var shoot_reload_time = 2


@onready var shoot_timer = $ShootTimer
@onready var dash_timer = $DashTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var horizontal_control_timer: Timer = $HorizontalControlTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var ammo_label = $CanvasLayer/AmmoLabel
@onready var currency_label: Label = $CanvasLayer/CurrencyLabel
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox2D = $Hurtbox
@onready var inventory: Inventory = $Inventory
@onready var attack: Sprite2D = $Attack
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_menu: GameMenu = $GameMenu

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var horizontal_control = true
var ammo

var facing = 1.0

func _ready():
	ammo = AMMO_CAPACITY
	ammo_label.text = str(ammo)
	currency_label.text = "0"
	dash_state = Enums.dash_states.cannot_dash
	jump_state = Enums.jump_states.cannot_jump

func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		game_menu.show()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += air_gravity_values() * gravity * delta
		if jump_state == Enums.jump_states.can_jump:
			jump_state = Enums.jump_states.coyote_time
			coyote_timer.start(coyote_time)
		
		# Perform a wall sLide
		if wall_jump_enabled and is_on_wall() and velocity.y > WALL_SLIDE_VELOCITY:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCITY, 100)
		if dash_state == Enums.dash_states.dashing:
			velocity.y = 0
	else:
		jump_state = Enums.jump_states.can_jump

	# Handle jump and wall jump
	if Input.is_action_just_pressed("jump"):
		if (is_on_floor() and jump_state == Enums.jump_states.can_jump) or jump_state ==  Enums.jump_states.coyote_time:
			jump_state = Enums.jump_states.jumping
			velocity.y = JUMP_VELOCITY
			play_particle(SPARKS, Vector2(0, 1))
		elif is_on_wall() and wall_jump_enabled:
			jump_state = Enums.jump_states.wall_jumping
			velocity = WALL_JUMP_VELOCITY
			velocity.x *= get_wall_normal().x
			horizontal_control = false
			horizontal_control_timer.start(wall_jump_control_loss_time)
			play_particle(SPARKS, Vector2(1, -get_wall_normal().x).normalized())
	
	


	# Handle variable jump height (early release)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y /= 4
		horizontal_control = true


	# Get the input direction
	var direction = Input.get_axis("left", "right")
	facing = direction if direction != 0 else facing
	if wall_jump_enabled and is_on_wall() and not is_on_floor():
		facing = get_wall_normal().x
	
	# Handle dashing
	if Input.is_action_just_pressed("dash") and dash_state == Enums.dash_states.can_dash:
		velocity.x = DASH_SPEED * facing
		velocity.y = 0
		horizontal_control = false
		horizontal_control_timer.start(dash_control_loss_time)
		dash_state = Enums.dash_states.dashing
		dash_timer.start(dash_time)
		play_particle(DASH_CLOUD, Vector2(-facing, 0))
	
	# Reset dash if wall jumped or jumped
	if is_on_floor() or (wall_jump_enabled and is_on_wall()):
		if dash_state == Enums.dash_states.has_dashed:
			dash_state = Enums.dash_states.can_dash
	
	# Stop dashing if hit wall
	if is_on_wall() and dash_state == Enums.dash_states.dashing:
		dash_state = Enums.dash_states.has_dashed
	
	
	# Handle the movement/deceleration.
	if horizontal_control == true:
		if not Input.is_action_pressed("lock") and direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	# Limit max velocity forever
	velocity = velocity.clamp(-TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	
	
	# Handle attack inputs
	if Input.is_action_pressed("shoot") and shooting_enabled:
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
		shooting_enabled = false
		if ammo <= 0:
			shoot_timer.start(shoot_reload_time)
			ammo_label.text = "reloading..."
		else:
			shoot_timer.start(shoot_time)
			ammo_label.text = str(ammo)
	
	if Input.is_action_just_pressed("melee"):
		if facing > 0:
			animation_player.play("attack_right")
		else:
			animation_player.play("attack_left")
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
	if inventory.buffer.currency > 0:
		currency_label.text +=  " + " + str(inventory.buffer.currency)


func _on_inventory_collected() -> void:
	currency_label.text = str(inventory.inventory_items.currency)

# Reload
func _on_shoot_timer_timeout():
	shooting_enabled = true
	if ammo <= 0:
		ammo = AMMO_CAPACITY
		ammo_label.text = str(ammo)

func _on_dash_timer_timeout():
	if dash_state == Enums.dash_states.dashing:
		dash_state = Enums.dash_states.has_dashed

func _on_horizontal_control_timer_timeout() -> void:
	horizontal_control = true

func _on_health_death() -> void:
	print("dead")

# Invincbility and fake knockback when character is hit
func _on_hurtbox_take_damage(attack: Attack) -> void:
	health.take_damage(attack)
	velocity = attack.direction * attack.force
	hurtbox.set_deferred("monitorable", false)
	invincibility_timer.start(hit_invincibility_time)
	horizontal_control = false
	horizontal_control_timer.start(hit_control_loss_time)

func _on_invincibility_timer_timeout() -> void:
	hurtbox.set_deferred("monitorable", true)

func _on_coyote_timer_timeout() -> void:
	if jump_state == Enums.jump_states.coyote_time:
		jump_state = Enums.jump_states.jumping

# Fake knockback to character when its hits connect
func _on_melee_attack_hitbox_hit(attack: Attack, collision_layer: int) -> void:
	if not is_on_floor():
		velocity.y = -80
	if collision_layer == 16:
		velocity.x = -attack.direction.x * 80
		horizontal_control = false
		horizontal_control_timer.start(0.1)

# TODO: bullet spark direction
# TODO: Handle can dash can jump with animations
# TODO: add HUD and menus
# TODO: Composite knockback
# TODO: Remove fake knockback as well as uneccessary collision layer param for hitbox hit
