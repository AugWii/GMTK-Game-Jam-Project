extends Node2D

@onready var main_menu = $MainMenu
@onready var level: CurrentLevel = $"Current Level"
@onready var pausemenu: Control = $GUI/Control/PauseMenu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") && !main_menu.visible:
		pausemenu.visible = !pausemenu.visible
		get_tree().paused = pausemenu.visible

func _ready() -> void:
	get_tree().paused = true
	main_menu.visible = true

func _physics_process(_delta: float) -> void:
	pass

func _on_main_menu_start_game() -> void:
	level.LoadLevel(1)
	countdown_func()
	
func countdown_func() -> void:
	# MUSIC STOP
	$Music/TANKENSTEIN.stop()
	$Music/SKELETANK.stop()
	$"Music/TANK O LANTERN".stop()
	$"Music/COUNT TANKULA".stop()
	get_tree().paused = true
	var countdown_ui = $GUI/Control/Countdown
	var countdown_label: Label = $GUI/Control/Countdown/CountdownLabel
	var countdown: int = 3
	countdown_label.add_theme_font_size_override("font_size", 40)
	countdown_ui.visible = true
	countdown_label.text = "Level " + str(level.curr_level_num)
	await get_tree().create_timer(1.0).timeout
	while countdown > 0:
		countdown_label.text = str(countdown)
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
	# MUSIC
	if level.curr_level_num >= 1:
		$Music/TANKENSTEIN.play()
		$Music/SKELETANK.play()
	if level.curr_level_num >= 3:
		$"Music/TANK O LANTERN".play()
	if level.curr_level_num >= 5:
		$"Music/COUNT TANKULA".play()
	
	
	if level.curr_level_num == 5:
		countdown_label.add_theme_font_size_override("font_size", 120)
		countdown_label.text = "TAKE THE COUNT DOWN!!!"
		$Audio/EvilLaugh.play()
		await get_tree().create_timer(2.0).timeout
	elif level.curr_level_num == 6:
		countdown_label.add_theme_font_size_override("font_size", 120)
		countdown_label.text = "TANKS FOR PLAYING!!!"
		$Audio/VictorySound.play()
		await get_tree().create_timer(5.0).timeout
	elif level.curr_level_num != 6:
		countdown_label.text = "Start!"
		await get_tree().create_timer(1.0).timeout
	countdown_ui.visible = false
	get_tree().paused = false

func level_lose() -> void:
	level.LoadLevel(level.curr_level_num)
	countdown_func()

func _on_current_level_level_complete() -> void:
	countdown_func()

func _on_resume_pressed() -> void:
	pausemenu.visible = !pausemenu.visible
	get_tree().paused = pausemenu.visible

func _on_return_pressed() -> void:
	get_tree().paused = false
	main_menu.visible = true
	pausemenu.visible = false
	level.LoadLevel(0)
