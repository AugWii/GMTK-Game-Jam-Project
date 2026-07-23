extends CharacterBody2D
class_name Player

# basic player movement attributes
@export var move_speed_f: float = 100
@export var move_speed_b: float = 80
@export var turn_speed: float = 3

# bullet to be shot
@export var bullet_scene: PackedScene

@onready var hitbox: CollisionShape2D = $CollisionShape2D

# attributes for shooting
@onready var cooldown_timer: Timer = $CooldownTimer
@export var shot_cooldown: float = 1
var shot_on_cooldown: bool = false

# cannon attributes
@onready var cannon_sprite: Sprite2D = $Cannon
var cannon_angle: float = 0

# movement states
var moving_dir: int = 0
var turning: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_forward"):
		moving_dir = 1
	elif event.is_action_released("move_forward") && moving_dir == 1:
		moving_dir = 0
	if event.is_action_pressed("move_backward"):
		moving_dir = -1
	elif event.is_action_released("move_backward") && moving_dir == -1:
		moving_dir = 0
	if event.is_action_pressed("turn_left"):
		turning = -1
	elif event.is_action_released("turn_left") && turning == -1:
		turning = 0
	if event.is_action_pressed("turn_right"):
		turning = 1
	elif event.is_action_released("turn_right") && turning == 1:
		turning = 0
	
	if event.is_action_pressed("shoot") && !shot_on_cooldown:
		var new_bullet = bullet_scene.instantiate()
		get_tree().root.add_child(new_bullet)
		new_bullet.fire(rotation + cannon_angle, position, hitbox.shape.radius + 2, true)
		shot_on_cooldown = true
		cooldown_timer.start(shot_cooldown)

func _physics_process(_delta: float) -> void:
	cannon_angle = get_angle_to(get_global_mouse_position()) + deg_to_rad(90)
	cannon_sprite.rotation = cannon_angle
	
	if turning != 0:
		rotate(turning * deg_to_rad(turn_speed))
	elif moving_dir != 0:
		velocity = Vector2.ZERO
		if moving_dir > 0:
			velocity.y = -move_speed_f
		elif moving_dir < 0:
			velocity.y = move_speed_b
		velocity = velocity.rotated(rotation)
		move_and_slide()

func _on_cooldown_timer_timeout() -> void:
	shot_on_cooldown = false

func player_hit() -> void:
	print("player hit")
