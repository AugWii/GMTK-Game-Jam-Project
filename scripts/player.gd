extends CharacterBody2D
class_name Player

# basic player movement attributes
@export var move_speed_f: float = 130
@export var move_speed_b: float = 100
@export var turn_speed: float = 3

# bullet to be shot
@export var bullet_scene: PackedScene
@onready var hitbox: CollisionShape2D = $CollisionShape2D

# attributes for shooting
@onready var cooldown_timer: Timer = $CooldownTimer
@export var shot_cooldown: float = 0.2
var shot_on_cooldown: bool = false

# cannon attributes
@onready var cannon_sprite: Sprite2D = $Cannon
var cannon_angle: float = 0

# movement states
var moving_dir: int = 0
var turning: int = 0

@onready var bullets_container: Node = $Bullets
@export var bullet_cap: int = 5

@onready var rewind_timer: Timer = $RewindCountTimer
var rewind_pos: Array[Vector4]
@export var total_rewind_time: float = 5
var is_rewinding: bool = false
@export var rewind_factor: float = 4

@onready var vulnerable_timer: Timer = $VulnerableTimer
var is_vulnerable: bool = false

func _ready() -> void:
	rewind_timer.start()

func _input(event: InputEvent) -> void:
	if is_rewinding:
		return
	
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
		if bullets_container.get_child_count() < bullet_cap:
			var new_bullet = bullet_scene.instantiate()
			bullets_container.add_child(new_bullet)
			new_bullet.fire(rotation + cannon_angle, position, hitbox.shape.radius + 30, true)
			shot_on_cooldown = true
			cooldown_timer.start(shot_cooldown)

func _physics_process(_delta: float) -> void:
	if is_rewinding:
		return
	
	cannon_angle = get_angle_to(get_global_mouse_position()) + deg_to_rad(90)
	cannon_sprite.rotation = cannon_angle
	
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
	shot_on_cooldown = false

func player_hit() -> void:
	if is_vulnerable:
		is_vulnerable = false
		$Body.material.set_shader_parameter("is_vulnerable", false)
		cannon_sprite.material.set_shader_parameter("is_vulnerable", false)
		$/root/Main.countdown_func()
		return
	if rewind_pos.size() > 0:
		is_rewinding = true
		moving_dir = 0
		turning = 0
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true
		
		var pos_tween = create_tween()
		for pos in rewind_pos:
			pos_tween.tween_property($".", "position", Vector2(pos.x, pos.y), rewind_timer.wait_time / rewind_factor)
			if pos.z < 0:
				pos.z += deg_to_rad(360)
			pos_tween.parallel().tween_property($".", "rotation", pos.z, rewind_timer.wait_time / rewind_factor)
			pos_tween.parallel().tween_property(cannon_sprite, "rotation", pos.w, rewind_timer.wait_time / rewind_factor)
			rewind_pos.erase(pos)
		pos_tween.parallel().tween_property(cannon_sprite, "rotation", get_angle_to(get_global_mouse_position()) + deg_to_rad(90), rewind_timer.wait_time / 4)
		await pos_tween.finished
		
		is_vulnerable = true
		$Body.material.set_shader_parameter("is_vulnerable", true)
		cannon_sprite.material.set_shader_parameter("is_vulnerable", true)
		vulnerable_timer.start(total_rewind_time)
		process_mode = Node.PROCESS_MODE_INHERIT
		get_tree().paused = false
		is_rewinding = false

func _on_rewind_count_timer_timeout() -> void:
	if rewind_pos.size() >= total_rewind_time * (1 / rewind_timer.wait_time):
		rewind_pos.pop_back()
	rewind_pos.push_front(Vector4(position.x, position.y, rotation, cannon_sprite.rotation))

func _on_vulnerable_timer_timeout() -> void:
	$Body.material.set_shader_parameter("is_vulnerable", false)
	cannon_sprite.material.set_shader_parameter("is_vulnerable", false)
	is_vulnerable = false
