extends Node2D

const HUB_SIZE=5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var joints = Array()
var rodCount = 0
var attachedRods = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	var shape = get_node("Hub/CollisionShape2D")
	var rect = RectangleShape2D.new()
	rect.set_extents(Vector2(HUB_SIZE, HUB_SIZE))
	shape.set_shape(rect)
	get_parent().connect("gravity_change", self, "on_gravity_change")
	
	
func _process(delta):
	var hub = get_node("Hub")
	for joint in joints:
		joint.position = hub.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func attach_rod(rod):
	attachedRods.append(rod)
	var hub = get_node("Hub")
	var joint = PinJoint2D.new()
	joint.set_softness(0.3)
	joint.position = hub.position
	add_child(joint)
	joint.set_node_a(hub.get_path())
	joint.set_node_b(rod.get_node("Line").get_path())
	joints.append(joint)
	rodCount += 1
	
	
func delete():
	for rod in attachedRods:
		if rod.startElbow == self:
			rod.startElbow = null

		if rod.endElbow == self:
			rod.endElbow = null
			
	var hub = get_node("Hub")
	for joint in joints:
		joint.queue_free()
	hub.queue_free()
	get_parent().elbowCount -= 1
	self.queue_free()

	
func on_gravity_change(gravityStatus):
	var hub = get_node("Hub")
	if gravityStatus:
		hub.set_mode(RigidBody2D.MODE_RIGID)
	else:
		hub.set_mode(RigidBody2D.MODE_STATIC)
		
func remove_rod(rod):

	var pathToLine = rod.get_node("Line").get_path()
	var jointToDelete = null
	
	var idx = attachedRods.find(rod)
	if idx < 0:
		return idx
	
	rodCount -= 1
	attachedRods.remove(idx)
	for joint in joints:
		if joint.get_node_b() == pathToLine:
			jointToDelete = joint
	
	if jointToDelete:
		joints.erase(jointToDelete)
		jointToDelete.queue_free()
		
	return 0

