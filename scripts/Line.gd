extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dragging=false
var translate_by=null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _integrate_forces(state):
	print("MOTION ", translate_by)
	if dragging and translate_by:
		var t = state.get_transform()
		state.set_transform(
			Transform2D(
				t.get_rotation(),
				t.get_origin() + translate_by
			)
		)
	

	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
