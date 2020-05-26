extends Node2D

const ACTIVE_TORQUE=40000

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var circleCollider
var rb
var current_torque=0
var elbow=null
var deleted=false

#elbows placed on the edges
var elbowNorth
var elbowEast
var elbowSouth
var elbowWest

var ELBOW = preload("res://scenes/Elbow.tscn")

# Called when the node enters the scene tree for the first time.

func get_outer_elbows():
	return [elbowNorth, elbowEast, elbowSouth, elbowWest]

func setup_side_elbow(x, y):
	var elbow = ELBOW.instance()
	elbow.position = Vector2(rb.position.x+x, rb.position.y+y)
	get_parent().add_child(elbow)
	elbow.attach_wheel(self)
	elbow.hub.get_node("CollisionShape2D").disabled=true
	
	return elbow

func _ready():
	rb = get_node("WheelBody")
	globals.connect(globals.GRAVITY_CHANGE_SIGNAL, self, "set_mode")
	
	var radius = circleCollider.shape.get_radius()
	elbowNorth = setup_side_elbow(0, -radius)
	elbowEast = setup_side_elbow(radius, 0)
	elbowSouth = setup_side_elbow(0, radius)
	elbowWest = setup_side_elbow(-radius, 0)

func activate_torque(backwards=false):
	current_torque=ACTIVE_TORQUE
	if backwards:
		current_torque *= -1
	rb.set_applied_torque(current_torque)
func deactivate_torque():
	current_torque=0
	rb.set_applied_torque(current_torque)

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
	rb = get_node("WheelBody")
	circleCollider = get_node("WheelBody/CollisionShape2D")
	set_mode(gravityOn) 
	circleCollider.set_shape(circleCollider.get_shape().duplicate(true))
	rb.position = pos
	
func delete():
	deleted=true
	print("deleting wheel")
	#rb.queue_free()
	for elb in [elbow, elbowNorth, elbowEast, elbowSouth, elbowWest]:
		if elb:
			if elb.rodCount <= 0:
				elb.delete()		
			else:
				elb.remove_wheel()

	self.queue_free()
	if self == get_parent().activeWheelInstance:
		get_parent().activeWheelInstance=null
	if self == get_parent().hoveredWheelInstance:
		get_parent().hoveredWheelInstance=null
	print("finished deleting wheel")
	
func _on_WheelBody_mouse_entered():
	print("hovering wheel")
	get_parent().hoveredWheelInstance=self


func _on_WheelBody_mouse_exited():
	if get_parent().hoveredWheelInstance == self:
		get_parent().hoveredWheelInstance=null

