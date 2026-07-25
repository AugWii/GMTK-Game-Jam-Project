extends CharacterBody2D
class_name Enemy

# basic player movement attributes
@export var move_speed_f: float = 130
@export var move_speed_b: float = 100
@export var turn_speed: float = 3

# bullet to be shot
@export var bullet_scene: PackedScene
@onready var hitbox: CollisionShape2D = $CollisionShape2D

# attributes for shooting
@onready var cooldown_timer: Timer = $CooldownTimer
@export var shot_cooldown: float = 0.6
var shot_on_cooldown: bool = false

# cannon attributes
@onready var cannon_sprite: Sprite2D = $Cannon
var cannon_angle: float = 0

# movement states
var moving_dir: int = 0
var turning: int = 0

@onready var bullets_container: Node = $Bullets
@export var bullet_cap: int = 2

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@export var player: Player
var playerSighted: bool = false;

#rewind stuff
@onready var rewind_timer: Timer = $RewindCountTimer
var rewind_pos: Array[Vector4]
@export var total_rewind_time: float = 5
var is_rewinding: bool = false
@export var rewind_factor: float = 4


func _physics_process(_delta: float) -> void:
	if is_rewinding:
		return
	
	checkForPlayer()
	
	if playerSighted:
		cannon_angle = get_angle_to(player.position) + deg_to_rad(90)
		cannon_sprite.rotation = cannon_angle
	else:
		cannon_sprite.rotation = 0
	
	#Screen Wrap Code:
	var screen_rect: Rect2 = Rect2(-get_viewport_rect().get_center(), get_viewport_rect().size)
	var y_size = screen_rect.size.y/2
	var x_size = screen_rect.size.x/2
	if !screen_rect.has_point(global_position):
		if -global_position.y > y_size + 1:
			global_position.y = y_size
		elif global_position.y > y_size + 1:
			global_position.y = -y_size
		if -global_position.x > x_size + 1:
			global_position.x = x_size
		elif global_position.x > x_size + 1:
			global_position.x = -x_size
	#movment and rotation:
	if turning != 0:
		rotate(turning * deg_to_rad(turn_speed))
	if moving_dir != 0:
		velocity = Vector2.ZERO
		if moving_dir > 0:
			velocity.y = -move_speed_f
		elif moving_dir < 0:
			velocity.y = move_speed_b
		velocity = velocity.rotated(rotation)
		move_and_slide()

func _on_cooldown_timer_timeout() -> void:
	if is_rewinding:
		return
	
	if playerSighted:
		if bullets_container.get_child_count() < bullet_cap:
			moving_dir = 0
			
			var new_bullet = bullet_scene.instantiate()
			bullets_container.add_child(new_bullet)
			new_bullet.fire(rotation + cannon_angle, position, hitbox.shape.radius + 30, true)
			shot_on_cooldown = true
			cooldown_timer.start(shot_cooldown)
		else:
			moving_dir = 1

func checkForPlayer() -> void:
	#Check for line of sight to player
	var space_state = get_world_2d().direct_space_state
	var checkStart = position
	var checkEnd = player.position
	var query = PhysicsRayQueryParameters2D.create(checkStart, checkEnd)
	query.exclude = [get_rid(), player.get_rid(), bullet_scene.get_rid()]
	query.collision_mask = 2 #only see collisions on physical layer 2
	var result = space_state.intersect_ray(query)
	
	if(result): playerSighted = false
	else: playerSighted = true

func player_hit() -> void:
	print("player hit")

func get_hit():
	if rewind_pos.size() > 0:
		is_rewinding = true
		
		#TODO: set shader
		
		moving_dir = 0
		turning = 0
		
		var pos_tween = create_tween()
		for pos in rewind_pos:
			if(rewind_pos.size() > 0): 
				pos_tween.tween_property($".", "position", Vector2(pos.x, pos.y), rewind_timer.wait_time / rewind_factor)
				
				if pos.z < 0:
					pos.z += deg_to_rad(360)
				
				var shortest_cannon_angle = cannon_sprite.rotation + angle_difference(cannon_sprite.rotation, pos.w)
				
				pos_tween.parallel().tween_property($".", "rotation", pos.z, rewind_timer.wait_time / rewind_factor)
				pos_tween.parallel().tween_property(cannon_sprite, "rotation", shortest_cannon_angle, rewind_timer.wait_time / rewind_factor)
				
				rewind_pos.erase(pos)
			
		var shortest_cannon_angle = cannon_sprite.rotation + angle_difference(cannon_sprite.rotation, get_angle_to(get_global_mouse_position()) + deg_to_rad(90))
		pos_tween.parallel().tween_property(cannon_sprite, "rotation", shortest_cannon_angle, rewind_timer.wait_time / 4)
		await pos_tween.finished
		
		#TODO: remove shader
		
		is_rewinding = false

#Pathfinding Code:
func makePath() -> void:
	nav_agent.target_position = player.position

func _on_timer_timeout() -> void:
	makePath()
	
	#move forwards towards player
	var angleToPlayer = to_local(nav_agent.get_next_path_position()).normalized().angle()
	rotation += angleToPlayer + deg_to_rad(90);
	moving_dir = 1;

func _on_rewind_count_timer_timeout() -> void:
	if(!is_rewinding): rewind_pos.push_front(Vector4(position.x, position.y, rotation, cannon_sprite.rotation)) #do nothingif rewinding
	
	if(rewind_pos.size() <= 0): queue_free() #destroy enemy if it goes past queue
