extends Node2D


#motor must have a direct link to the things it is controlling
var rb
var collider
var elbow
var deleted=false

var obj_type = globals.TOOLS.MOTORTOOL

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
	if elbow:
		if elbow.rodCount <= 0:
			elbow.delete()		
		else:
			elbow.remove_wheel()

	self.queue_free()
	if self == get_parent().hoveredObjInstance:
		get_parent().hoveredObjInstance=null
		

func get_attached_wheels():
	var attachedWheels = Array()
	for rod in elbow.attachedRods:
		for otherElbow in [rod.startElbow, rod.endElbow]:
			
			if (otherElbow != elbow and 
				otherElbow.attachedObj and 
				otherElbow.attachedObj.obj_type == globals.TOOLS.WHEELTOOL):
				attachedWheels.append(otherElbow.attachedObj)
	return attachedWheels
				
	

func set_mode(gravityStatus):
	if gravityStatus:
		rb.set_mode(RigidBody2D.MODE_RIGID)

	else:
		rb.set_mode(RigidBody2D.MODE_STATIC)


func _on_PhysBody_mouse_entered():
	#print(len(get_attached_wheels()))
	
	var attached_wheels = get_attached_wheels()
	
	print(len(attached_wheels))
	
	for wheel in attached_wheels:
		wheel.activate_torque()
		wheel.rb.set_sleeping(false)
	
	get_parent().hoveredObjInstance=self


func _on_PhysBody_mouse_exited():
	if get_parent().hoveredObjInstance == self:
		get_parent().hoveredObjInstance=null
