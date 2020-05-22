extends "res://scripts/Draggable.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var wheel

# Called when the node enters the scene tree for the first time.
func _ready():
	wheel = get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func delete():
	wheel.delete()


func _on_WheelBody_input_event(viewport, event, shape_idx):
	._input_event(viewport, event, shape_idx)
