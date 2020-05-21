extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var lineTool
var moveTool
var eraseTool
var wheelTool
var main
signal test

# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_parent()
	lineTool = get_node("Line")
	moveTool = get_node("Move")
	eraseTool = get_node("Erase")
	wheelTool = get_node("Wheel")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Linetool_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		eraseTool.get_node("Active").set_visible(false)
		moveTool.get_node("Active").set_visible(false)
		lineTool.get_node("Active").set_visible(true)
		wheelTool.get_node("Active").set_visible(false)
		main.lineToolOn=true
		main.moveToolOn=false
		main.eraseToolOn=false
		main.wheelToolOn=false


func _on_Movetool_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		eraseTool.get_node("Active").set_visible(false)
		moveTool.get_node("Active").set_visible(true)
		lineTool.get_node("Active").set_visible(false)
		wheelTool.get_node("Active").set_visible(false)
		main.lineToolOn=false
		main.moveToolOn=true
		main.eraseToolOn=false
		main.wheelToolOn=false


func _on_Erasetool_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		eraseTool.get_node("Active").set_visible(true)
		moveTool.get_node("Active").set_visible(false)
		lineTool.get_node("Active").set_visible(false)
		wheelTool.get_node("Active").set_visible(false)
		main.lineToolOn=false
		main.moveToolOn=false
		main.eraseToolOn=true
		main.wheelToolOn=false

	#pass # Replace with function body.


func _on_Wheeltool_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		eraseTool.get_node("Active").set_visible(false)
		moveTool.get_node("Active").set_visible(false)
		lineTool.get_node("Active").set_visible(false)
		wheelTool.get_node("Active").set_visible(true)
		main.lineToolOn=false
		main.moveToolOn=false
		main.eraseToolOn=false
		main.wheelToolOn=true
