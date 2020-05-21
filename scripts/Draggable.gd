extends RigidBody2D

#thank you to KidsCanCode for most of this code. Awesome tutorial!

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var held=false
var clickDelta = Vector2.ZERO
var rod

# Called when the node enters the scene tree for the first time.
func _ready():
	rod = get_parent()
	#pass # Replace with function body.
	
func _input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton 
		and event.button_index == BUTTON_LEFT
		and event.is_pressed()):
		globals.emit_signal("clicked", self)
		
func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position() - clickDelta
		
func pickup():
	if held:
		return
	clickDelta = get_global_mouse_position() - global_transform.get_origin()
	mode = RigidBody2D.MODE_STATIC
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		mode = RigidBody2D.MODE_RIGID
		apply_central_impulse(impulse)
		#set_sleeping(false)
		held = false
		
func delete():
	rod.delete()

