extends Node2D

const ACTIVE_TORQUE=4000

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var circleCollider
var rb
var current_torque=0
var elbow=null
var deleted=false
# Called when the node enters the scene tree for the first time.
func _ready():
	rb = get_node("WheelBody")
	globals.connect(globals.GRAVITY_CHANGE_SIGNAL, self, "set_mode")

func activate_torque():
	current_torque=ACTIVE_TORQUE
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
	if elbow:
		if elbow.rodCount <= 1:
			elbow.delete()		
		else:
			elbow.remove_wheel()

	self.queue_free()
	if self == get_parent().activeWheelInstance:
		get_parent().activeWheelInstance=null
	if self == get_parent().hoveredWheelInstance:
		get_parent().hoveredWheelInstance=null
	print("finished deleting wheel")
	
func _on_WheelBody_mouse_entered():
	get_parent().hoveredWheelInstance=self


func _on_WheelBody_mouse_exited():
	get_parent().hoveredWheelInstance=null


func _on_VisibilityNotifier2D_screen_exited():
	if not deleted:
		delete()