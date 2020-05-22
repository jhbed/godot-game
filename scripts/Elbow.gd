extends Node2D

const HUB_SIZE=3
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var joints = Array()
var wheelJoint = null
var rodCount = 0
var attachedRods = Array()
var attachedWheel = null
var hub

# Called when the node enters the scene tree for the first time.
func _ready():
	var shape = get_node("Hub/CollisionShape2D")
	var rect = RectangleShape2D.new()
	hub = get_node("Hub")
	rect.set_extents(Vector2(HUB_SIZE, HUB_SIZE))
	shape.set_shape(rect)
	globals.connect(globals.GRAVITY_CHANGE_SIGNAL, self, "on_gravity_change")
	
	
func _process(delta):
	for joint in joints:
		joint.position = hub.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func attach_rod(rod):
	
	for otherRod in attachedRods:
		rod.rb.add_collision_exception_with(otherRod.rb)
		
	if attachedWheel:
		rod.rb.add_collision_exception_with(attachedWheel.rb)
		
	rod.rb.add_collision_exception_with(hub)
	
	attachedRods.append(rod)
	var joint = PinJoint2D.new()
	joint.set_softness(0.3)
	joint.set_visible(false)
	joint.position = hub.position
	add_child(joint)
	joint.set_node_a(hub.get_path())
	joint.set_node_b(rod.get_node("Line").get_path())
	joints.append(joint)
	rodCount += 1
	print("attached rod")
	
func remove_wheel():
	if wheelJoint:
		wheelJoint.queue_free()
	wheelJoint = null
	attachedWheel = null
	
func attach_wheel(wheel):
	
	for otherRod in attachedRods:
		print("active wheel ", wheel)
		print("other rod ", otherRod.rb)
		wheel.rb.add_collision_exception_with(otherRod.rb)
		
	wheel.rb.add_collision_exception_with(hub)
	
	attachedWheel = wheel
	
	wheelJoint = PinJoint2D.new()
	wheelJoint.set_softness(0.3)
	wheelJoint.set_visible(false)
	wheelJoint.position = hub.position
	add_child(wheelJoint)
	wheelJoint.set_node_a(hub.get_path())
	wheelJoint.set_node_b(wheel.get_node("WheelBody").get_path())
	wheel.elbow = self
	wheel.activate_torque()
	
	
func delete():
	
	if attachedWheel:
		attachedWheel.elbow = null
	
	for rod in attachedRods:
		if rod.startElbow == self:
			rod.startElbow = null

		if rod.endElbow == self:
			rod.endElbow = null
			
	for joint in joints:
		joint.queue_free()
	hub.queue_free()
	get_parent().elbowCount -= 1
	self.queue_free()

	
func on_gravity_change(gravityStatus):
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

