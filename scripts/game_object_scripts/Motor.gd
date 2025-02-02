extends Node2D

const ACTIVE_TORQUE=40000
signal wheel_deleted

var currentTorque = 0

#motor must have a direct link to the things it is controlling
var rb
var collider
var elbow
var deleted=false
var attached_wheels : Array

const obj_type = globals.TOOLS.MOTORTOOL

func set_elbow(elb):
	elbow=elb
	attached_wheels = get_attached_wheels()

func _ready():
	globals.connect(globals.GRAVITY_CHANGE_SIGNAL, self, "set_mode")

func init(pos, gravityOn):
	rb = get_node("PhysBody")
	collider = get_node("PhysBody/CollisionShape2D")
	set_mode(gravityOn) 
	collider.set_shape(collider.get_shape().duplicate(true))
	rb.position = pos
	
func get_outer_elbows():
	#we dont have any outer elbows yet
	return []
	
func delete():
	deleted=true
	#rb.queue_free()
	
	get_parent().activeMotor=null
	
	
	if elbow:
		if elbow.rodCount <= 0:
			elbow.delete()		
		else:
			elbow.remove_wheel()

	self.queue_free()
	if self == get_parent().hoveredObjInstance:
		get_parent().hoveredObjInstance=null
		
	for wheel in attached_wheels:
		wheel.rb.set_applied_torque(0)
		

func get_attached_wheels():
	var attachedWheels = Array()
	for rod in elbow.attachedRods:
		for otherElbow in [rod.startElbow, rod.endElbow]:
			
			if (otherElbow != elbow and 
				otherElbow.attachedObj and 
				otherElbow.attachedObj.obj_type == globals.TOOLS.WHEELTOOL):
				attachedWheels.append(otherElbow.attachedObj)
				if not otherElbow.attachedObj.is_connected("wheel_deleted", self, "_on_attached_wheel_delete"):
					otherElbow.attachedObj.connect("wheel_deleted", self, "_on_attached_wheel_delete")
	return attachedWheels
				
	

func set_mode(gravityStatus):
	if not deleted:
		if gravityStatus:
			rb.set_mode(RigidBody2D.MODE_RIGID)
	
		else:
			rb.set_mode(RigidBody2D.MODE_STATIC)


func _on_PhysBody_mouse_entered():
	#print(len(get_attached_wheels()))
	get_parent().hoveredObjInstance=self


func _on_PhysBody_mouse_exited():
	if get_parent().hoveredObjInstance == self:
		get_parent().hoveredObjInstance=null
		

func apply_torque(amount):
	
	currentTorque += ACTIVE_TORQUE * amount
	if currentTorque > ACTIVE_TORQUE:
		currentTorque = ACTIVE_TORQUE
	if currentTorque < -ACTIVE_TORQUE:
		currentTorque = -ACTIVE_TORQUE
	
	set_wheel_torque(currentTorque)
		
func set_wheel_torque(amt):
	for wheel in attached_wheels:
		if not wheel.deleted:
			wheel.rb.set_applied_torque(amt);
		
func _on_rb_right_click():
	if get_parent().activeMotor:
		get_parent().activeMotor.active_texture(false)
	get_parent().activeMotor=self
	active_texture(true)
	
func active_texture(isActive):
	rb.get_node("ActiveTexture").visible= isActive
	rb.get_node("InactiveTexture").visible= not isActive
	
func _on_rod_delete(rod):
	set_wheel_torque(0)
	attached_wheels = get_attached_wheels()
	set_wheel_torque(currentTorque)
	
func _on_attached_wheel_delete(wheel):
	attached_wheels.erase(wheel)


