extends Node2D

var gravityOn=true



var state = globals.TOOLS.LINETOOL

var MULTITOOL = preload("res://scenes/main/MultiTool.tscn")
var multiTool

var heldObject=null

func _input(event):
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		
		if event.is_pressed() and state == globals.TOOLS.LINETOOL:
			multiTool.start_drawing_line()
			
		elif event.is_pressed() and state in globals.PHYS_OBJECTS:
			multiTool.init_new_object(state)
			
		elif heldObject and !event.is_pressed():
			heldObject.drop(Input.get_last_mouse_speed())
			heldObject = null
				
	elif event is InputEventMouseMotion:
		multiTool.update_active_draw()
		
	elif event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_G:
			set_scene_gravity()	
		if event.scancode == KEY_R:
			multiTool.backwards_wheel = not multiTool.backwards_wheel

# Called when the node enters the scene tree for the first time.
func _ready():
	multiTool = MULTITOOL.instance()
	add_child(multiTool)
	globals.connect(globals.INTERACTIVE_OBJECT_CLICKED, self, "_on_draggable_clicked")
	#Physics2DServer.area_set_param(get_world_2d().space, 
				#Physics2DServer.AREA_PARAM_GRAVITY_VECTOR, 
				#Vector2.ZERO)
func set_scene_gravity():
	gravityOn = not gravityOn
	#if gravityOn:
		#print("Gravity ON")
	#else:
		#print("Gravity OFF")
	globals.emit_signal(globals.GRAVITY_CHANGE_SIGNAL, gravityOn)
#	for obj in rods:
#		obj.set_mode(gravityOn)

#observer callback
func _on_draggable_clicked(object):
	
	print("draggable clicked ", object.name)
	if state == globals.TOOLS.ERASETOOL:
		object.delete()
	elif !heldObject and state == globals.TOOLS.MOVETOOL:
		print("PICKEDUP")
		heldObject = object
		heldObject.pickup()
	elif heldObject and state == globals.TOOLS.MOVETOOL:
		print("DROP")
		heldObject.drop()
	
func log_state():
	print("Elbow count ", multiTool.elbowCount)
	print("Rod count ", multiTool.rodCount)




