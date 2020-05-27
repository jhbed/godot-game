tool
extends Area2D

signal tool_clicked(tool_id)

export (globals.TOOLS) var tool_id
export(Texture) var texture setget set_texture
export(bool) var isActive setget set_isActive
export(Vector2) var textureScale = Vector2(0.1, 0.1) setget set_textureScale

func set_textureScale(vec):
	textureScale = vec 
	$Sprite.scale = vec

func set_isActive(active):
	isActive = active
	$Active.visible=active

func set_texture(tex):
	texture = tex
	$Sprite.set_texture(tex)

func _ready() -> void:
	connect("tool_clicked", get_parent().get_parent(), "_on_tool_clicked")
	


func _on_ToolBarTool_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#since this is a tool script we only want this when not in editor
	if not Engine.editor_hint:
		if event is InputEventMouseButton and event.is_pressed():
			emit_signal("tool_clicked", tool_id)
