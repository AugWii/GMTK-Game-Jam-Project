extends Node2D

var velocity: Vector2 = Vector2.ZERO
@onready var life_timer = $Timer
@export var bullet_speed: float = 200

func fire(rotation_direction_rad: float, start_pos: Vector2, spawn_distance: float):
	life_timer.start(5)
	position = start_pos
	rotate(rotation_direction_rad)
	velocity.y = -bullet_speed
	velocity = velocity.rotated(rotation_direction_rad)
	position += velocity.normalized() * spawn_distance

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_timer_timeout() -> void:
	queue_free()
