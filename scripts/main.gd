extends Node2D

@onready var player: Player = $Player
@onready var main_menu = $MainMenu
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	get_tree().paused = true
	main_menu.visible = true

func _physics_process(_delta: float) -> void:
	pass

func _on_main_menu_start_game() -> void:
	var countdown_ui = $GUI/Control/Countdown
	var countdown_label: Label = $GUI/Control/Countdown/CountdownLabel
	var countdown: int = 3
	countdown_ui.visible = true
	while countdown > 0:
		countdown_label.text = str(countdown)
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
	countdown_label.text = "Start!"
	await get_tree().create_timer(1.0).timeout
	countdown_ui.visible = false
	get_tree().paused = false
