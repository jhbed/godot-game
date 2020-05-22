extends Node2D

var LINE_COLOR = ColorN("Yellow")
const LINE_WIDTH = 3.0
const JOINT_RADIUS = 4.0
const NEAR_JOINT_RADIUS = 7.0

var ROD = preload("res://scenes/Rod.tscn")
var ELBOW = preload("res://scenes/Elbow.tscn")
var WHEEL = preload("res://scenes/Wheel.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lineIsActive = false
var lineStart = Vector2(0,0)
var activeLineEnd = Vector2()
var hoveredRodInstance = null
var hoveredWheelInstance = null
var activeRodInstance = null
var activeWheelInstance = null
var activeSegment=null
var canDrawLines = true


var elbowCount = 0
var rodCount = 0

func _draw():
	if lineIsActive:
		draw_circle(lineStart, JOINT_RADIUS, LINE_COLOR)
		draw_line(lineStart, activeLineEnd, LINE_COLOR, LINE_WIDTH)
		draw_circle(activeLineEnd, JOINT_RADIUS, LINE_COLOR)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		
func _physics_process(delta):
	if activeRodInstance:
		lineStart = activeRodInstance.get_coord(activeSegment)
	elif activeWheelInstance:
		lineStart = activeWheelInstance.rb.global_transform.get_origin()
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
	elif activeWheelInstance:
		pos1 = activeWheelInstance.rb.global_transform.get_origin()
			
	if rod2 != null:
		pos2 = rod2.get_coord(rod2Idx)
		elbow2 = rod2.get_elbow(rod2Idx)
		if elbow2 == null:
			elbow2 = init_new_elbow(pos2, rod2, rod2Idx)
	elif hoveredWheelInstance:
		pos2 = hoveredWheelInstance.rb.global_transform.get_origin()
	
	var rodInst = ROD.instance()
	rodInst.init(pos1, pos2, get_parent().gravityOn)
	add_child(rodInst)
	
	if rod1 != null:
		elbow1.attach_rod(rodInst)
		rodInst.add_elbow(elbow1, rodInst.ROD_START)
	elif activeWheelInstance:
		elbow1 = init_new_elbow(pos1, rodInst, rodInst.ROD_START)
		elbow1.attach_wheel(activeWheelInstance)
		rodInst.add_elbow(elbow1, rodInst.ROD_START)
		
	if rod2 != null:
		elbow2.attach_rod(rodInst)
		rodInst.add_elbow(elbow2, rodInst.ROD_END)
	elif hoveredWheelInstance:
		elbow2 = init_new_elbow(pos2, rodInst, rodInst.ROD_END)
		elbow2.attach_wheel(hoveredWheelInstance)
		rodInst.add_elbow(elbow2, rodInst.ROD_END)
		
		
	rodCount += 1
	get_parent().log_state()
	
func init_new_wheel():
	#inits a new wheel. It is possible a rod exists here so 
	#put it on the rod if that is the case

	if !canDrawLines:
		return
		
	var rod = null
	var elbow = null
	var pos = get_global_mouse_position()
	if hoveredRodInstance != null:
		rod = hoveredRodInstance
		var rodIdx = rod.isActive
		pos = rod.get_coord(rodIdx)
		elbow = rod.get_elbow(rodIdx)
		if elbow == null:
			elbow = init_new_elbow(pos, rod, rodIdx)
			
	var wheelInst = WHEEL.instance()
	wheelInst.init(pos, get_parent().gravityOn)
	add_child(wheelInst)
	if rod:
		elbow.attach_wheel(wheelInst)
		wheelInst.activate_torque()
	
			

func start_drawing_line():
	if not canDrawLines:
		return
	lineIsActive = not lineIsActive
	if lineIsActive:
		if hoveredRodInstance:
			activeRodInstance = hoveredRodInstance
			lineStart = activeRodInstance.get_active_seg_coord()
			activeSegment = activeRodInstance.isActive
		elif hoveredWheelInstance:
			activeWheelInstance = hoveredWheelInstance
			lineStart = activeWheelInstance.rb.global_transform.get_origin()
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
		activeWheelInstance=null
		
func update_active_draw():
	if lineIsActive:
		activeLineEnd = get_global_mouse_position()
		


	
