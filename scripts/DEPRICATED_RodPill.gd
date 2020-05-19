extends Node2D

var ROD_COLOR = ColorN("Blue")
const ROD_THICKNESS = 3.0
const JOINT_RADIUS = 4.0
const NEAR_JOINT_RADIUS = 7.0

var pill
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var startPosition=0
var endPosition=0

func init(startPos, endPos):
	
	pill = get_node("Line/CollisionShape2D")
	pill.set_shape(pill.get_shape().duplicate(true))
	var pillHeight = pill.shape.get_height()
	pill.shape.set_radius(ROD_THICKNESS)
	
	startPosition = startPos
	endPosition = endPos
	
	var dist = startPos.distance_to(endPos)
	pill.shape.set_height(dist)
	var offset = dist / 2
	pill.position.y-=offset
	
	position = startPos
	var rot = startPos.angle_to_point(endPos) - (PI/2)
	rotate(rot)
	

		

func _ready():
	pass
	
func _draw():
	var startPos = position
	var height = pill.shape.get_height()
	print(rotation)
	#var endPos = startPos + Vector2(height, height)
	#draw_circle(startPos, JOINT_RADIUS, ROD_COLOR)
	#draw_circle(endPos, JOINT_RADIUS, ROD_COLOR)
	#draw_line(startPos, endPos, ROD_COLOR, ROD_THICKNESS)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
