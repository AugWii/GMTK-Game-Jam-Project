extends CharacterBody2D

@onready var life_timer = $LifeTimer
@export var bullet_speed: float = 4

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

enum teams {PLAYER, ENEMY}
var bullet_team: int = teams.PLAYER

@export var total_bounces: int = 1
var bouces_left: int = 0

# called when the bullet is created
func fire(rotation_direction_rad: float, start_pos: Vector2, spawn_distance: float, player_shot: bool):
	if player_shot:
		bullet_team = teams.PLAYER
	else:
		bullet_team = teams.ENEMY
	life_timer.start(5)
	position = start_pos
	rotate(rotation_direction_rad)
	velocity.y = -bullet_speed
	velocity = velocity.rotated(rotation_direction_rad)
	position += velocity.normalized() * spawn_distance
	bouces_left = total_bounces

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		rotation = velocity.angle() + deg_to_rad(90)
		bouces_left -= 1

func _on_life_timer_timeout() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	var valid_hit = false
	if body is Enemy:
		body.get_hit()
		valid_hit = true
	elif bouces_left == 0:
		valid_hit = true
	
	if valid_hit:
		queue_free()
