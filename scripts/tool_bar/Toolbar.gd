extends Node2D

var main


func _ready() -> void:
	main = get_tree().get_root().get_node("Main")


func set_active_tool(tool_id):
	for node in get_node("Tools").get_children():
		if node.tool_id == tool_id:
			node.get_node("Active").set_visible(true)
		else:
			node.get_node("Active").set_visible(false)


func _on_ToolbarArea_mouse_entered():
	main.multiTool.canDrawLines = false


func _on_ToolbarArea_mouse_exited():
	main.multiTool.canDrawLines = true
	
func _on_tool_clicked(tool_id):
	main.state = tool_id
	if tool_id == globals.TOOLS.BG_LINE_TOOL:
		main.multiTool.bg = true
		main.state = globals.TOOLS.LINETOOL
	else:
		main.multiTool.bg = false
		main.state = tool_id
	set_active_tool(tool_id)
		
