extends RigidBody2D
signal right_clicked

var held=false
var clickDelta = Vector2.ZERO
var parent
var priorMode = RigidBody2D.MODE_RIGID

func _ready():
	set_pickable(true) #this stupid thing had me pulling my hair out for hours... WHY???
	parent = get_parent()
	connect("input_event", self, "_on_SelectableArea_input_event")
	connect("right_clicked", get_parent(), "_on_rb_right_click")
	
	
func delete():
	traverse_and_set_sleeping(get_assoc_elbow())
	parent.delete()
	

#func _on_SelectableArea_input_event(viewport, event, shape_idx):
#	_input_event(viewport, event, shape_idx)

	
#func _input_event(viewport, event, shape_idx):
#	if (event is InputEventMouseButton 
#		and event.button_index == BUTTON_LEFT
#		and event.is_pressed()):
#		globals.emit_signal(globals.INTERACTIVE_OBJECT_CLICKED, self)
		
func _physics_process(delta):
	if held:
		var newTrans = get_global_mouse_position() - clickDelta
		var moveDelta = newTrans - global_transform.origin
		var startElbow = get_assoc_elbow()
		traverse_and_move_graph(startElbow, {}, moveDelta)
		

func get_assoc_elbow():
	if get_parent().obj_type in globals.PHYS_OBJECTS:
		
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
	print("drop called")
	if held:
		#set_sleeping(false)
		held = false
		var startElbow = get_assoc_elbow()
		print("Graph size ", traverse_and_set_mode(startElbow, {}, priorMode))
		apply_central_impulse(impulse)

		
func traverse_and_count_elbows(elbow, visited={}):
	
	visited[elbow] = 1
	var count = 1
	
	for rod in elbow.attachedRods:
		if rod.startElbow != elbow and not visited.has(rod.startElbow):
			count += traverse_and_count_elbows(rod.startElbow, visited)
		if rod.endElbow != elbow and not visited.has(rod.endElbow):
			count += traverse_and_count_elbows(rod.endElbow, visited)
			
	return count
	
func traverse_and_set_sleeping(elbow, visited={}, sleeping=false):
	elbow.hub.set_sleeping(sleeping)
	visited[elbow] = 1
	var count = 1
	
	if elbow.attachedObj:
		elbow.attachedObj.rb.set_sleeping(sleeping)
		for elb in elbow.attachedObj.get_outer_elbows():
			elb.hub.set_sleeping(sleeping)
	
	for rod in elbow.attachedRods:
		rod.rb.set_sleeping(sleeping)
		if rod.startElbow != elbow and not visited.has(rod.startElbow):
			count += traverse_and_set_sleeping(rod.startElbow, visited, sleeping)
		if rod.endElbow != elbow and not visited.has(rod.endElbow):
			count += traverse_and_set_sleeping(rod.endElbow, visited, sleeping)
			
	return count
	
func traverse_and_set_mode(elbow, visited={}, newMode=RigidBody2D.MODE_STATIC):
	elbow.hub.set_mode(newMode)
	visited[elbow] = 1
	var count = 1
	
	if elbow.attachedObj:
		elbow.attachedObj.rb.set_mode(newMode)
		for elb in elbow.attachedObj.get_outer_elbows():
			elb.hub.set_mode(newMode)
	
	for rod in elbow.attachedRods:
		rod.rb.set_mode(newMode)
		if rod.startElbow != elbow and not visited.has(rod.startElbow):
			count += traverse_and_set_mode(rod.startElbow, visited, newMode)
		if rod.endElbow != elbow and not visited.has(rod.endElbow):
			count += traverse_and_set_mode(rod.endElbow, visited, newMode)
			
	return count
	
func traverse_and_move_graph(elbow, visited={}, delta=Vector2.ZERO):
	
	elbow.hub.global_transform.origin += delta
	visited[elbow] = 1
	var count = 1
	
	if elbow.attachedObj:
		elbow.attachedObj.rb.global_transform.origin += delta
		for elb in elbow.attachedObj.get_outer_elbows():
			elb.hub.global_transform.origin += delta
	
	for rod in elbow.attachedRods:
		
		if visited.has(rod):
			continue
		else:
			visited[rod] = 1
		
		rod.rb.global_transform.origin += delta
		if rod.startElbow != elbow and not visited.has(rod.startElbow):
			count += traverse_and_move_graph(rod.startElbow, visited, delta)
		if rod.endElbow != elbow and not visited.has(rod.endElbow):
			count += traverse_and_move_graph(rod.endElbow, visited, delta)
	return count

func _on_SelectableArea_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton 
		and event.button_index == BUTTON_LEFT
		and event.is_pressed()):
		globals.emit_signal(globals.INTERACTIVE_OBJECT_CLICKED, self)
		
	if (event is InputEventMouseButton 
		and event.button_index == BUTTON_RIGHT
		and event.is_pressed()):
			emit_signal("right_clicked")
			
