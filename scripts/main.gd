extends Node2D

@onready var main_menu = $MainMenu
@onready var camera: Camera2D = $Camera2D
@onready var level: CurrentLevel = $"Current Level"

func _ready() -> void:
	get_tree().paused = true
	main_menu.visible = true

func _physics_process(_delta: float) -> void:
	pass

func _on_main_menu_start_game() -> void:
	level.LoadLevel(1)
	countdown_func()
	
func countdown_func() -> void:
	get_tree().paused = true
	var countdown_ui = $GUI/Control/Countdown
	var countdown_label: Label = $GUI/Control/Countdown/CountdownLabel
	var countdown: int = 3
	countdown_ui.visible = true
	countdown_label.text = "Level " + str(level.curr_level_num)
	await get_tree().create_timer(1.0).timeout
	while countdown > 0:
		countdown_label.text = str(countdown)
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
	countdown_label.text = "Start!"
	await get_tree().create_timer(1.0).timeout
	countdown_ui.visible = false
	get_tree().paused = false

func level_lose() -> void:
	level.LoadLevel(level.curr_level_num)
	countdown_func()

func _on_current_level_level_complete() -> void:
	countdown_func()
