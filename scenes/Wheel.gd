extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var circleCollider
var rb
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_mode(gravityStatus):
	if gravityStatus:
		rb.set_mode(RigidBody2D.MODE_RIGID)
		rb.set_applied_torque(2000)
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
	queue_free()
	
	
