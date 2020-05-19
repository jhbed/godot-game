extends Node2D

var LINE_COLOR = ColorN("Yellow")
const LINE_WIDTH = 3.0
const JOINT_RADIUS = 4.0
const NEAR_JOINT_RADIUS = 7.0

var ROD = preload("res://scenes/Rod.tscn")
var ELBOW = preload("res://scenes/Elbow.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lineIsActive = false
var lineStart = Vector2()
var activeLineEnd = Vector2()
var gravityOn = true
var rods = Array()
var elbows = Array()
var hoveredRodInstance = null
var activeSegment=null

func _input(event):
	
	if event is InputEventMouseButton and event.is_pressed():
		lineIsActive = not lineIsActive
		
		if lineIsActive:
			#lineStart = event.position
			hoveredRodInstance=null
			activeSegment=null
			for otherRod in rods:
				activeSegment = otherRod.isActive
				if activeSegment != otherRod.ROD_NONE:
					lineStart = otherRod.get_active_seg_coord()
					hoveredRodInstance = otherRod
					break
					
			if not hoveredRodInstance:
				lineStart = get_global_mouse_position()
			else:
				print("attaching to ", hoveredRodInstance)
				
		else:
			var secondAttachment=null
			var secondIdx=null
			for otherRod in rods:
				secondIdx = otherRod.isActive
				if secondIdx != otherRod.ROD_NONE:
					secondAttachment = otherRod
					print("attaching to ", otherRod)
					break
			init_new_rod(hoveredRodInstance, 
						 activeSegment, 
						 secondAttachment, 
						secondIdx)
			
			
			
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
	for obj in rods:
		obj.set_mode(gravityOn)
		
func _process(delta):
	if hoveredRodInstance:
		lineStart = hoveredRodInstance.get_coord(activeSegment)
	update()
	
func init_new_elbow(pos, rod, rodIdx):
	var elbow = ELBOW.instance()
	elbow.position = pos 
	add_child(elbow)
	rod.add_elbow(elbow, rodIdx)
	elbow.attach_rod(rod)
	elbows.append(elbow)
	return elbow
	
func init_new_rod(rod1, rod1Idx, rod2, rod2Idx):
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
	rods.append(rodInst)
	
	if rod1 != null:
		elbow1.attach_rod(rodInst)
		
	if rod2 != null:
		elbow2.attach_rod(rodInst)
	
