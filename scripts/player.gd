extends CharacterBody2D

@export var move_speed_f: float = 100
@export var move_speed_b: float = 80
@export var turn_speed: float = 3

var moving_dir: int = 0
var turning: int = 0

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_forward"):
		moving_dir = 1
	elif event.is_action_released("move_forward"):
		moving_dir = 0
	if event.is_action_pressed("move_backward"):
		moving_dir = -1
	elif event.is_action_released("move_backward"):
		moving_dir = 0
	if event.is_action_pressed("turn_left"):
		turning = -1
	elif event.is_action_released("turn_left"):
		turning = 0
	if event.is_action_pressed("turn_right"):
		turning = 1
	elif event.is_action_released("turn_right"):
		turning = 0

func _physics_process(_delta: float) -> void:
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
