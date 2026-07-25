extends CanvasLayer

signal start_game

func _on_play_button_pressed() -> void:
	visible = false
	start_game.emit()
