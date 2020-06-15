extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var rb
var circleCollider
var elbow=null
const obj_type = globals.TOOLS.THRUSTERTOOL
var elbowLeft = null
var elbowRight = null
var deleted=false
var thrusting=false

var ELBOW = preload("res://scenes/game_objects/Elbow.tscn")

func _physics_process(delta: float) -> void:
	if thrusting:
		print("thrusting")
		$PhysBody.apply_central_impulse(Vector2.UP * 30)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var points = $PhysBody/CollisionShape2D.shape.points
	var pos1 = ($PhysBody/CollisionShape2D.position + points[2]) * $PhysBody/CollisionShape2D.scale.x + Vector2(0,6)
	var pos2 = ($PhysBody/CollisionShape2D.position + points[3]) * $PhysBody/CollisionShape2D.scale.x + Vector2(0,6)
	elbowLeft = setup_side_elbow(pos1.x, pos1.y)
	elbowRight = setup_side_elbow(pos2.x, pos2.y)
	
func init(pos, gravityOn):
	rb = get_node("PhysBody")
	circleCollider = get_node("PhysBody/CollisionShape2D")
	set_mode(gravityOn) 
	circleCollider.set_shape(circleCollider.get_shape().duplicate(true))
	rb.position = pos
	
func set_mode(gravityStatus):
	if gravityStatus:
		rb.set_mode(RigidBody2D.MODE_RIGID)
	else:
		rb.set_mode(RigidBody2D.MODE_STATIC)
		
func set_elbow(elb):
	elbow = elb
	
func setup_side_elbow(x, y):
	var elbow = ELBOW.instance()
	elbow.position = Vector2(rb.position.x+x, rb.position.y+y)
	get_parent().add_child(elbow)
	elbow.attach_obj(self)
	elbow.hub.get_node("CollisionShape2D").disabled=true
	
	return elbow
	
func get_outer_elbows():
	return [elbowLeft, elbowRight]
	
func delete():
	deleted=true
	#rb.queue_free()
	for elb in [elbow, elbowLeft, elbowRight]:
		if elb:
			if elb.rodCount <= 0:
				elb.delete()
			else:
				elb.remove_wheel()
	
	self.queue_free()
	if self == get_parent().hoveredObjInstance:
		get_parent().hoveredObjInstance=null
		
	emit_signal("wheel_deleted", self)
	
func _on_rb_right_click():
	get_parent().activeThruster = self

func _on_Body_mouse_entered() -> void:
	pass # Replace with function body.


func _on_Body_mouse_exited() -> void:
	pass # Replace with function body.
