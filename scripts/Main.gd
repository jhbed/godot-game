extends Node2D

signal gravity_change(gravityStatus)

var LINE_COLOR = ColorN("Yellow")
const LINE_WIDTH = 3.0
const JOINT_RADIUS = 4.0
const NEAR_JOINT_RADIUS = 7.0

var ROD = preload("res://scenes/Rod.tscn")
var ELBOW = preload("res://scenes/Elbow.tscn")
var TOOLBAR = preload("res://scenes/Toolbar.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lineIsActive = false
var lineStart = Vector2(0,0)
var activeLineEnd = Vector2()
var gravityOn = true
var hoveredRodInstance = null
var activeRodInstance = null
var activeSegment=null
var canDrawLines = true
var lineToolOn = true
var moveToolOn = false
var eraseToolOn = false

var elbowCount = 0
var rodCount = 0

func _input(event):
	
	if event is InputEventMouseButton and event.is_pressed() and canDrawLines and lineToolOn:
		lineIsActive = not lineIsActive
		
		if lineIsActive:
			if hoveredRodInstance:
				activeRodInstance = hoveredRodInstance
				lineStart = activeRodInstance.get_active_seg_coord()
				activeSegment = activeRodInstance.isActive
			else:
				lineStart = get_global_mouse_position()
		else:
			var secondAttachment=null
			var secondIdx=null
			if hoveredRodInstance:
				secondIdx = hoveredRodInstance.isActive
				#if secondIdx != hoveredRodInstance.ROD_NONE:
				secondAttachment = hoveredRodInstance
			init_new_rod(activeRodInstance, 
						 activeSegment, 
						 secondAttachment, 
						secondIdx)
			activeRodInstance=null
				
	elif event is InputEventMouseMotion and lineIsActive:
		activeLineEnd = get_global_mouse_position()
		
	elif event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_G:
			set_scene_gravity()	

func _draw():
	if lineIsActive:
		draw_circle(lineStart, JOINT_RADIUS, LINE_COLOR)
		draw_line(lineStart, activeLineEnd, LINE_COLOR, LINE_WIDTH)
		draw_circle(activeLineEnd, JOINT_RADIUS, LINE_COLOR)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#Physics2DServer.area_set_param(get_world_2d().space, 
				#Physics2DServer.AREA_PARAM_GRAVITY_VECTOR, 
				#Vector2.ZERO)
func set_scene_gravity():
	gravityOn = not gravityOn
	emit_signal("gravity_change", gravityOn)
#	for obj in rods:
#		obj.set_mode(gravityOn)
		
func _physics_process(delta):
	if activeRodInstance:
		lineStart = activeRodInstance.get_coord(activeSegment)
	update()
	
func init_new_elbow(pos, rod, rodIdx):
	var elbow = ELBOW.instance()
	elbow.position = pos 
	add_child(elbow)
	rod.add_elbow(elbow, rodIdx)
	elbow.attach_rod(rod)
	elbowCount+=1
	return elbow
	
func init_new_rod(rod1, rod1Idx, rod2, rod2Idx):
	#inits a new rod between lineStart and global_mouse_position()
	#if connecting to a rod it should make a new elbow or use that rods elbow
	var elbow1=null
	var elbow2=null
	var pos1 = lineStart
	var pos2 = get_global_mouse_position()
	if rod1 != null:
		pos1 = rod1.get_coord(rod1Idx)
		elbow1 = rod1.get_elbow(rod1Idx)
		if elbow1 == null:
			elbow1 = init_new_elbow(pos1, rod1, rod1Idx)
			
	if rod2 != null:
		pos2 = rod2.get_coord(rod2Idx)
		elbow2 = rod2.get_elbow(rod2Idx)
		if elbow2 == null:
			elbow2 = init_new_elbow(pos2, rod2, rod2Idx)
	
	var rodInst = ROD.instance()
	rodInst.init(pos1, pos2, gravityOn)
	add_child(rodInst)
	
	if rod1 != null:
		elbow1.attach_rod(rodInst)
		rodInst.add_elbow(elbow1, rodInst.ROD_START)
		
	if rod2 != null:
		elbow2.attach_rod(rodInst)
		rodInst.add_elbow(elbow2, rodInst.ROD_END)
		
	rodCount += 1
	log_state()
	
func log_state():
	print("Elbow count ", elbowCount)
	print("Rod count ", rodCount)


func _on_ToolbarArea_mouse_entered():
	canDrawLines = false


func _on_ToolbarArea_mouse_exited():
	canDrawLines = true
