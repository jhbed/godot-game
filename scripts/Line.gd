extends "res://scripts/Draggable.gd"
#extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	rod = get_parent()
	
#when selectable area does something we call the draggable interface
	
func delete():
	rod.delete()


func _on_SelectableArea_input_event(viewport, event, shape_idx):
	._input_event(viewport, event, shape_idx)
