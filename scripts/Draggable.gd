extends RigidBody2D

#thank you to KidsCanCode for most of this code. Awesome tutorial!

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var held=false
var clickDelta = Vector2.ZERO
var rod
var priorMode = RigidBody2D.MODE_RIGID

func _ready():
	pass

	
func _input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton 
		and event.button_index == BUTTON_LEFT
		and event.is_pressed()):
		globals.emit_signal(globals.INTERACTIVE_OBJECT_CLICKED, self)
		
func _physics_process(delta):
	if held:
		var newTrans = get_global_mouse_position() - clickDelta
		var moveDelta = newTrans - global_transform.origin
		var startElbow = get_assoc_elbow()
		traverse_and_move_graph(startElbow, {}, moveDelta)
		
#func pickup():
#	if held:
#		return
#	clickDelta = get_global_mouse_position() - global_transform.get_origin()
#	priorMode = get_mode()
#	mode = RigidBody2D.MODE_STATIC
#	held = true

func get_assoc_elbow():
	if self.name == 'WheelBody':
		return get_parent().elbow
	else:
		return get_parent().startElbow
	
	
func pickup():
	if held:
		return
	clickDelta = get_global_mouse_position() - global_transform.get_origin()
	priorMode = get_mode()
	#mode = RigidBody2D.MODE_STATIC
	held=true
	var startElbow = get_assoc_elbow()
	print("Graph size ", traverse_and_set_mode(startElbow, {}, RigidBody2D.MODE_STATIC))

func drop(impulse=Vector2.ZERO):
	if held:
		#set_sleeping(false)
		held = false
		var startElbow = get_assoc_elbow()
		print("Graph size ", traverse_and_set_mode(startElbow, {}, priorMode))
		apply_central_impulse(impulse)

#func drop(impulse=Vector2.ZERO):
#	if held:
#		mode = priorMode
#		apply_central_impulse(impulse)
#		#set_sleeping(false)
#		held = false
		
func traverse_and_count_elbows(elbow, visited={}):
	
	visited[elbow] = 1
	var count = 1
	
	for rod in elbow.attachedRods:
		if rod.startElbow != elbow and not visited.has(rod.startElbow):
			count += traverse_and_count_elbows(rod.startElbow, visited)
		if rod.endElbow != elbow and not visited.has(rod.endElbow):
			count += traverse_and_count_elbows(rod.endElbow, visited)
			
	return count
	
func traverse_and_set_mode(elbow, visited={}, newMode=RigidBody2D.MODE_STATIC):
	elbow.hub.set_mode(newMode)
	visited[elbow] = 1
	var count = 1
	
	if elbow.attachedWheel:
		elbow.attachedWheel.rb.set_mode(newMode)
	
	for rod in elbow.attachedRods:
		rod.rb.set_mode(newMode)
		if rod.startElbow != elbow and not visited.has(rod.startElbow):
			count += traverse_and_set_mode(rod.startElbow, visited, newMode)
		if rod.endElbow != elbow and not visited.has(rod.endElbow):
			count += traverse_and_set_mode(rod.endElbow, visited, newMode)
			
	return count
	
func traverse_and_move_graph(elbow, visited={}, delta=Vector2.ZERO):
	elbow.hub.transform.origin += delta
	visited[elbow] = 1
	var count = 1
	
	if elbow.attachedWheel:
		elbow.attachedWheel.rb.transform.origin += delta
	
	for rod in elbow.attachedRods:
		
		if visited.has(rod):
			continue
		else:
			visited[rod] = 1
		
		rod.rb.transform.origin += delta
		if rod.startElbow != elbow and not visited.has(rod.startElbow):
			count += traverse_and_move_graph(rod.startElbow, visited, delta)
		if rod.endElbow != elbow and not visited.has(rod.endElbow):
			count += traverse_and_move_graph(rod.endElbow, visited, delta)
			
	return count
		


