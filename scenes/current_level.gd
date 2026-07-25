extends Node2D
class_name CurrentLevel

@export var Level1:PackedScene
@export var Level2:PackedScene
@export var Level3:PackedScene
@export var Level4:PackedScene
@export var Level5:PackedScene

var currLevel:Node
var curr_level_num = 0
signal level_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !currLevel:
		return
	var enemies_left: int = 0
	for node in currLevel.get_children():
		if node is Enemy:
			enemies_left += 1
	
	if enemies_left == 0:
		LoadLevel(curr_level_num + 1)
		level_complete.emit()

func LoadLevel(levelNum:int) -> void:
	curr_level_num = levelNum
	for child in get_children():
		child.queue_free()
	if(levelNum == 1):
		currLevel = Level1.instantiate()
		call_deferred("add_child", currLevel)
	if(levelNum == 2):
		currLevel = Level2.instantiate()
		call_deferred("add_child", currLevel)
	if(levelNum == 3):
		currLevel = Level3.instantiate()
		call_deferred("add_child", currLevel)
	if(levelNum == 4):
		currLevel = Level4.instantiate()
		call_deferred("add_child", currLevel)
	if(levelNum == 5):
		currLevel = Level5.instantiate()
		call_deferred("add_child", currLevel)
	
	
	
