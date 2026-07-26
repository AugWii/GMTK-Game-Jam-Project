extends CharacterBody2D
class_name Bullet

@onready var life_timer = $LifeTimer
@export var bullet_speed: float = 10

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
	life_timer.start(10)
	position = start_pos
	rotate(rotation_direction_rad)
	velocity.y = -bullet_speed
	velocity = velocity.rotated(rotation_direction_rad)
	position += velocity.normalized() * spawn_distance
	bouces_left = total_bounces
	await get_tree().create_timer(0.1).timeout
	$CollisionShape2D.disabled = false

func _physics_process(_delta: float) -> void:
	var screen_rect: Rect2 = Rect2(-get_viewport_rect().get_center(), get_viewport_rect().size)
	var y_size = screen_rect.size.y/2
	var x_size = screen_rect.size.x/2
	if !screen_rect.has_point(position):
		if -position.y > y_size + 1:
			position.y = y_size
		elif position.y > y_size + 1:
			position.y = -y_size
		
		if -position.x > x_size + 1:
			position.x = x_size
		elif position.x > x_size + 1:
			position.x = -x_size
	
	var collision = move_and_collide(velocity)
	if collision:
		$"../../../../../Audio/BounceSound".play()
		velocity = velocity.bounce(collision.get_normal())
		rotation = velocity.angle() + deg_to_rad(90)
		if bouces_left == 0:
			queue_free()
		else:
			bouces_left -= 1
		

func _on_life_timer_timeout() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	var valid_hit = false
	if body is Enemy:
		#$"../../../../../Audio/ExplosionSound".play()
		body.get_hit()
		valid_hit = true
	if body is Player:
		body.player_hit()
		valid_hit = true
	if valid_hit:
		$"../../../../../Audio/BounceSound".play()
		queue_free()
