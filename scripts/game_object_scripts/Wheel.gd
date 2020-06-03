extends Node2D

signal wheel_deleted(wheel)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var circleCollider
var rb
var current_torque=0
var elbow=null
var deleted=false
const obj_type = globals.TOOLS.WHEELTOOL

#elbows placed on the edges
var elbowNorth
var elbowEast
var elbowSouth
var elbowWest

var ELBOW = preload("res://scenes/game_objects/Elbow.tscn")

# Called when the node enters the scene tree for the first time.

func get_outer_elbows():
	return [elbowNorth, elbowEast, elbowSouth, elbowWest]

func setup_side_elbow(x, y):
	var elbow = ELBOW.instance()
	elbow.position = Vector2(rb.position.x+x, rb.position.y+y)
	get_parent().add_child(elbow)
	elbow.attach_obj(self)
	elbow.hub.get_node("CollisionShape2D").disabled=true
	
	return elbow

func _ready():
	rb = get_node("PhysBody")
	globals.connect(globals.GRAVITY_CHANGE_SIGNAL, self, "set_mode")
	
	var radius = circleCollider.shape.get_radius()
	elbowNorth = setup_side_elbow(0, -radius)
	elbowEast = setup_side_elbow(radius, 0)
	elbowSouth = setup_side_elbow(0, radius)
	elbowWest = setup_side_elbow(-radius, 0)

func set_mode(gravityStatus):
	if gravityStatus:
		rb.set_mode(RigidBody2D.MODE_RIGID)
		rb.set_applied_torque(current_torque)
	else:
		rb.set_mode(RigidBody2D.MODE_STATIC)
		rb.set_applied_torque(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func init(pos, gravityOn):
	rb = get_node("PhysBody")
	circleCollider = get_node("PhysBody/CollisionShape2D")
	set_mode(gravityOn) 
	circleCollider.set_shape(circleCollider.get_shape().duplicate(true))
	rb.position = pos
	
func delete():
	deleted=true
	#rb.queue_free()
	for elb in [elbow, elbowNorth, elbowEast, elbowSouth, elbowWest]:
		if elb:
			if elb.rodCount <= 0:
				elb.delete()		
			else:
				elb.remove_wheel()

	self.queue_free()
	if self == get_parent().hoveredObjInstance:
		get_parent().hoveredObjInstance=null
		
	emit_signal("wheel_deleted", self)
	
func _on_WheelBody_mouse_entered():
	print("hovering wheel")
	get_parent().hoveredObjInstance=self


func _on_WheelBody_mouse_exited():
	if get_parent().hoveredObjInstance == self:
		get_parent().hoveredObjInstance=null
		
func set_elbow(elb):
	elbow=elb
		
func _on_rod_delete(rod):
	print("I can see that my friend was deleted")

func _on_rb_right_click():
	pass

