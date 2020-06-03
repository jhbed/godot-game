extends Node2D


var ROD = preload("res://scenes/game_objects/Rod.tscn")
var ELBOW = preload("res://scenes/game_objects/Elbow.tscn")
var WHEEL = preload("res://scenes/game_objects/Wheel.tscn")
var MOTOR = preload("res://scenes/game_objects/Motor.tscn")

var _physics_objects = {
	globals.TOOLS.WHEELTOOL : WHEEL,
	globals.TOOLS.MOTORTOOL : MOTOR
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lineIsActive = false
var lineStart = Vector2(0,0)
var activeLineEnd = Vector2()
var hoveredObjInstance = null
var canDrawLines = true
var hoveredElbow=null
var activeElbow=null
var activeMotor=null
var bg=false
var backwards_wheel=false


var elbowCount = 0
var rodCount = 0

func _draw():
	var color = globals.ROD_COLOR
	if bg:
		color = globals.BG_ROD_COLOR
	if lineIsActive:
		draw_circle(lineStart, globals.JOINT_RADIUS, color)
		draw_line(lineStart, activeLineEnd, color, globals.ROD_THICKNESS)
		draw_circle(activeLineEnd, globals.JOINT_RADIUS, color)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		
func _process(delta):
	update()


func init_new_elbow(pos):
	var elbow = ELBOW.instance()
	elbow.position = pos
	add_child(elbow)
	return elbow

func init_new_rod():
	if not activeElbow:
		activeElbow = init_new_elbow(lineStart)
	if not hoveredElbow:
		hoveredElbow = init_new_elbow(get_global_mouse_position())
	
	var rodInst = ROD.instance()
	rodInst.init(activeElbow.get_pos(), hoveredElbow.get_pos(), get_parent().gravityOn, bg)
	add_child(rodInst)
	
	rodInst.add_elbow(activeElbow, rodInst.ROD_START)
	rodInst.add_elbow(hoveredElbow, rodInst.ROD_END)
	activeElbow.attach_rod(rodInst)
	hoveredElbow.attach_rod(rodInst)
	

	
	activeElbow=null
	hoveredElbow=null
		
	
func start_drawing_line():
	if not canDrawLines:
		return
	lineIsActive = not lineIsActive
	if lineIsActive:
		if hoveredElbow:
			activeElbow = hoveredElbow
			lineStart = activeElbow.get_pos()
		else:
			lineStart = get_global_mouse_position()
	else:
		init_new_rod()
	
		
func update_active_draw():
	if lineIsActive:
		activeLineEnd = get_global_mouse_position()
		
		
func get_or_create_elbow():
	if hoveredElbow:
		return hoveredElbow
	else:
		return init_new_elbow(get_global_mouse_position())
	
			
func init_new_object(tool_id):
	
	if !canDrawLines or hoveredObjInstance:
		return
	
	var obj = _physics_objects[tool_id].instance()
	var elbow = get_or_create_elbow()
	var pos = elbow.get_pos()
	obj.init(pos, get_parent().gravityOn)
	add_child(obj)
	elbow.attach_obj(obj)
	

		


		


	
