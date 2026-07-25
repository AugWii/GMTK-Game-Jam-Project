extends Node2D

@export var Level1:PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func LoadLevel(levelNum:int) -> void:
	var currLevel:Node
	
	if(levelNum == 1):
		currLevel = Level1.instantiate()
		self.add_child(currLevel)
	
	
	
