extends Node2D


var ROD = preload("res://scenes/Rod.tscn")
var ELBOW = preload("res://scenes/Elbow.tscn")
var WHEEL = preload("res://scenes/Wheel.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lineIsActive = false
var lineStart = Vector2(0,0)
var activeLineEnd = Vector2()
var hoveredWheelInstance = null
var activeWheelInstance = null
var canDrawLines = true
var hoveredElbow=null
var activeElbow=null
var bg=false


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
		
func _physics_process(delta):
	update()	

func init_new_wheel():
	#inits a new wheel. It is possible a rod exists here so 
	#put it on the rod if that is the case
	if !canDrawLines or hoveredWheelInstance:
		return
		
	var elbow
	var pos = get_global_mouse_position()
	if hoveredElbow:
		elbow = hoveredElbow
		pos = elbow.get_pos()
	else:
		elbow = init_new_elbow(pos)
			
	var wheelInst = WHEEL.instance()
	wheelInst.init(pos, get_parent().gravityOn)
	add_child(wheelInst)
	elbow.attach_wheel(wheelInst)
	wheelInst.activate_torque()

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
	
	activeElbow.attach_rod(rodInst)
	rodInst.add_elbow(activeElbow, rodInst.ROD_START)
	hoveredElbow.attach_rod(rodInst)
	rodInst.add_elbow(hoveredElbow, rodInst.ROD_END)

	
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
		


		


	
