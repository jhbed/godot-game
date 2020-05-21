extends Node2D

#TODO
#make code that checks if you are near an edge an Area 2D with signal,
#that is probably more efficient then current system

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
var startArea
var endArea
var startPosActive=false
var endPosActive=false
var isActive=ROD_NONE
var rb
var lineSegment
var selectableArea
var startElbow=null
var endElbow=null
var hovering=false

func _ready():
	globals.connect(globals.GRAVITY_CHANGE_SIGNAL, self, "on_gravity_change")

func on_gravity_change(gravityStatus):
	set_mode(gravityStatus)
	
func _physics_process(delta):
	startPosition = get_start_coord()
	endPosition = get_end_coord()
	#check_active(get_global_mouse_position())
	update()
	
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

	
	
func _draw():	
	if startPosActive:
		draw_circle(startPosition, NEAR_JOINT_RADIUS, ROD_COLOR)
	else:
		draw_circle(startPosition, JOINT_RADIUS, ROD_COLOR)
	
	if endPosActive:
		draw_circle(endPosition, NEAR_JOINT_RADIUS, ROD_COLOR)
	else:
		draw_circle(endPosition, JOINT_RADIUS, ROD_COLOR)
		
	if hovering:
		draw_line(startPosition, endPosition, ROD_COLOR, ROD_THICKNESS+2)
	else:
		draw_line(startPosition, endPosition, ROD_COLOR, ROD_THICKNESS)
		
	

func init(startPos, endPos, gravityStatus):
	rb = get_node("Line")
	lineSegment = get_node("Line/CollisionShape2D")
	selectableArea = get_node("Line/SelectableArea/CollisionShape2D")
	startArea = get_node("Line/StartCircle")
	endArea = get_node("Line/EndCircle")
	selectableArea.set_shape(RectangleShape2D.new())
	startArea.get_node("CollisionShape2D").set_shape(CircleShape2D.new())
	endArea.get_node("CollisionShape2D").set_shape(CircleShape2D.new())
	
	set_mode(gravityStatus) 
	lineSegment.set_shape(lineSegment.get_shape().duplicate(true))
	
	var centerPoint = calcCenterPoint(startPos, endPos)
	var xLen = startPos.x - endPos.x
	var yLen = startPos.y - endPos.y
	var a = Vector2(xLen/2, yLen/2)
	var b = -a
	rb.position = centerPoint
	lineSegment.shape.set_a(a)
	startArea.position = a
	lineSegment.shape.set_b(b)
	endArea.position = b
	
	
	startPosition = startPos
	endPosition = endPos
	
	var length = startPos.distance_to(endPos)
	rb.set_weight(BASE_WEIGHT * length)
	selectableArea.shape.set_extents(Vector2(length/2, ROD_THICKNESS*2))
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
	if idx == ROD_START and startElbow != null:
		return startElbow
	if idx == ROD_END and endElbow != null:
		return endElbow
	return null
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func delete():
	for elbow in [startElbow, endElbow]:
		print(elbow)
		if elbow:
			var idx = elbow.attachedRods.find(self)
			if idx >= 0:
				elbow.remove_rod(self)
			if elbow.rodCount <= 1:
				elbow.delete()
	get_parent().rodCount -= 1
	self.queue_free()

func _on_StartCircle_mouse_entered():
	startPosActive=true
	endPosActive=false
	isActive=ROD_START
	get_parent().hoveredRodInstance = self

func _on_StartCircle_mouse_exited():
	startPosActive=false
	isActive=ROD_NONE
	get_parent().hoveredRodInstance = null
	
func _on_EndCircle_mouse_entered():
	startPosActive=false
	endPosActive=true
	isActive=ROD_END
	get_parent().hoveredRodInstance = self

func _on_EndCircle_mouse_exited():
	endPosActive=false
	isActive=ROD_NONE
	get_parent().hoveredRodInstance = null

func _on_SelectableArea_mouse_entered():
	if get_parent().get_parent().moveToolOn:
		hovering=true

func _on_SelectableArea_mouse_exited():
	hovering=false
