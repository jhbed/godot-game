extends Node2D

enum {ROD_START, ROD_END, ROD_NONE}
var ROD_COLOR = ColorN("Yellow")
const ROD_THICKNESS = 5.0
const JOINT_RADIUS = 4.0
const NEAR_JOINT_RADIUS = 7.0
const ROD_ATTACH_MOUSE_HOVER_DIST = 10
const BASE_WEIGHT = .098


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var startPosition=0
var endPosition=0
var startPosActive=false
var endPosActive=false
var isActive=ROD_NONE
var rb
var lineSegment
var selectableArea
var startElbow=null
var endElbow=null
var isDeletable=false

func _ready():
	pass
	
func _process(delta):
	startPosition = get_start_coord()
	endPosition = get_end_coord()
	check_active(get_global_mouse_position())
	update()
	
func _physics_process(delta):
	pass
	
func get_active_seg_coord():
	if startPosActive:
		return get_start_coord()
	if endPosActive:
		return get_end_coord()
	return null
	
func get_start_coord():
	return rb.to_global(lineSegment.shape.get_a())
	
func get_end_coord():
	return rb.to_global(lineSegment.shape.get_b())
	
func get_coord(startOrEnd): 
	if startOrEnd == ROD_START:
		return get_start_coord()
	if startOrEnd == ROD_END:
		return get_end_coord()
	return null

	
func check_active(mouse_pos):
	
	if (mouse_pos.distance_to(startPosition) < 
		ROD_ATTACH_MOUSE_HOVER_DIST):
		startPosActive = true
		endPosActive= false

	elif (mouse_pos.distance_to(endPosition) < 
		ROD_ATTACH_MOUSE_HOVER_DIST):
		endPosActive=true
		startPosActive=false
		
	else:
		endPosActive=false
		startPosActive = false
		
	if startPosActive:
		isActive = ROD_START
	elif endPosActive:
		isActive = ROD_END
	else:
		isActive = ROD_NONE
	
	
func _draw():	
	if startPosActive:
		draw_circle(startPosition, NEAR_JOINT_RADIUS, ROD_COLOR)
	else:
		draw_circle(startPosition, JOINT_RADIUS, ROD_COLOR)
	
	if endPosActive:
		draw_circle(endPosition, NEAR_JOINT_RADIUS, ROD_COLOR)
	else:
		draw_circle(endPosition, JOINT_RADIUS, ROD_COLOR)
	draw_line(startPosition, endPosition, ROD_COLOR, ROD_THICKNESS)
	

func init(startPos, endPos, gravityStatus):
	rb = get_node("Line")
	lineSegment = get_node("Line/CollisionShape2D")
	selectableArea = get_node("Line/SelectableArea/CollisionShape2D")
	selectableArea.set_shape(RectangleShape2D.new())
	
	set_mode(gravityStatus) 
	lineSegment.set_shape(lineSegment.get_shape().duplicate(true))
	
	var centerPoint = calcCenterPoint(startPos, endPos)
	var xLen = startPos.x - endPos.x
	var yLen = startPos.y - endPos.y
	var a = Vector2(xLen/2, yLen/2)
	var b = -a
	rb.position = centerPoint
	lineSegment.shape.set_a(a)
	lineSegment.shape.set_b(b)
	
	startPosition = startPos
	endPosition = endPos
	
	var length = startPos.distance_to(endPos)
	rb.set_weight(BASE_WEIGHT * length)
	selectableArea.shape.set_extents(Vector2(length/2, ROD_THICKNESS))
	#deletableArea.rotation = Vector2.RIGHT.angle()
	var rot = startPos.angle_to_point(endPos)
	selectableArea.rotate(rot)
	

func set_mode(gravityStatus):
	if gravityStatus:
		rb.set_mode(rb.MODE_RIGID)
		#gravity = 98
	else:
		#gravity = 0
		rb.set_mode(rb.MODE_STATIC)

func calcCenterPoint(pos1, pos2):
	return Vector2((pos1.x + pos2.x)/2, (pos1.y + pos2.y)/2)
	
func add_elbow(elbow, idx):
	if idx == ROD_START:
		startElbow = elbow
	if idx == ROD_END:
		endElbow = elbow
		
func get_elbow(idx):
	if idx == ROD_START:
		return startElbow
	if idx == ROD_END:
		return endElbow
	return null
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
