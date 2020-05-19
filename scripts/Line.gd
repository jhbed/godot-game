extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		print("WHOAH")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_mouse_entered():
	print("HELLO THERE BUDDY")


func _on_Line_mouse_entered():
	print("BLAH")
