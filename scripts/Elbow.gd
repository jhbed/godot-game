extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var joints = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	for joint in joints:
		var hub = get_node("Hub")
		joint.position = hub.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func attach_rod(rod):
	var hub = get_node("Hub")
	var joint = PinJoint2D.new()
	joint.set_softness(1)
	joint.position = hub.position
	add_child(joint)
	joint.set_node_a(hub.get_path())
	joint.set_node_b(rod.get_node("Line").get_path())
	joints.append(joint)
	
func attach_rods(rod1, rod2):
	attach_rod(rod1)
	attach_rod(rod2)

