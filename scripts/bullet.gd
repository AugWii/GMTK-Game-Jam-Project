extends Node2D

var velocity: Vector2 = Vector2.ZERO
@onready var life_timer = $LifeTimer
@export var bullet_speed: float = 400

enum teams {PLAYER, ENEMY}
var bullet_team: int = teams.PLAYER

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

func _physics_process(delta: float) -> void:
	position += velocity * delta

# called when the bullet hits something
func _on_body_entered(body: Node2D) -> void:
	var valid_hit = false
	if body is Enemy:
		body.get_hit()
		valid_hit = true
	elif body is Player && bullet_team == teams.ENEMY:
		body.player_hit()
		valid_hit = true
	
	if valid_hit:
		queue_free()

func _on_life_timer_timeout() -> void:
	queue_free()
