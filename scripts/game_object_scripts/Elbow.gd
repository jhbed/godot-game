extends Node2D

const HUB_SIZE=3
var SOFTNESS = 0.3
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var joints = Array()
var objJoint = null
var rodCount = 0
var attachedRods = Array()
var attachedObj = null
var hub
var active=false

# Called when the node enters the scene tree for the first time.
func _ready():
	var shape = get_node("Hub/CollisionShape2D")
	var rect = RectangleShape2D.new()
	hub = get_node("Hub")
	rect.set_extents(Vector2(HUB_SIZE, HUB_SIZE))
	shape.set_shape(rect)
	globals.connect(globals.GRAVITY_CHANGE_SIGNAL, self, "on_gravity_change")
	
func _draw():
	if active:
		draw_circle(hub.position, globals.NEAR_JOINT_RADIUS, globals.ROD_COLOR)
	else:
		draw_circle(hub.position, globals.JOINT_RADIUS, globals.ROD_COLOR)
	
	
func get_pos():
	return hub.global_transform.get_origin()

func _process(delta):
	for joint in joints:
		joint.position = hub.position
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func attach_rod(rod):
	
	for otherRod in attachedRods:
		rod.rb.add_collision_exception_with(otherRod.rb)
		
	if attachedObj:
		var isSide=false
		for elb in attachedObj.get_outer_elbows():
			if elb == self:
				isSide=true
		if not isSide:
			rod.rb.add_collision_exception_with(attachedObj.rb)
		
	rod.rb.add_collision_exception_with(hub)
	
	attachedRods.append(rod)
	var joint = PinJoint2D.new()
	joint.set_softness(SOFTNESS)
	joint.set_visible(false)
	joint.position = hub.position
	add_child(joint)
	joint.set_node_a(hub.get_path())
	joint.set_node_b(rod.get_node("Body").get_path())
	joints.append(joint)
	rodCount += 1
	
func remove_wheel():
	print("removing wheel")
	if objJoint:
		objJoint.queue_free()
	objJoint = null
	attachedObj = null
	
func attach_obj(obj):
	
	for otherRod in attachedRods:
		obj.rb.add_collision_exception_with(otherRod.rb)
		
	obj.rb.add_collision_exception_with(hub)
	
	attachedObj = obj
	
	objJoint = PinJoint2D.new()
	objJoint.set_softness(SOFTNESS)
	objJoint.set_visible(false)
	objJoint.position = hub.position
	add_child(objJoint)
	objJoint.set_node_a(hub.get_path())
	objJoint.set_node_b(obj.get_node("PhysBody").get_path())
	obj.elbow = self
	#obj.activate_torque()
	
	
	
func delete():
	
	if attachedObj:
		attachedObj.elbow = null
	
	for rod in attachedRods:
		if rod.startElbow == self:
			rod.startElbow = null

		if rod.endElbow == self:
			rod.endElbow = null
			
#	for joint in joints:
#		joint.queue_free()
#	hub.queue_free()
	get_parent().elbowCount -= 1
	self.queue_free()
	if get_parent().hoveredElbow == self:
		get_parent().hoveredElbow=null

	
func on_gravity_change(gravityStatus):
	if gravityStatus:
		hub.set_mode(RigidBody2D.MODE_RIGID)
	else:
		hub.set_mode(RigidBody2D.MODE_STATIC)
		
func remove_rod(rod):

	var pathToLine = rod.get_node("Body").get_path()
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



func _on_SelectableArea_mouse_entered():
	active=true
	get_parent().hoveredElbow=self


func _on_SelectableArea_mouse_exited():
	active=false
	if get_parent().hoveredElbow == self:
		get_parent().hoveredElbow=null
