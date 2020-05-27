extends Node2D

enum {ROD_START, ROD_END, ROD_NONE}

var startPosition=0
var endPosition=0
var rb
var lineSegment
var selectableArea
var startElbow=null
var endElbow=null
var hovering=false
var deleted=false
var bg = false

func _ready():
	globals.connect(globals.GRAVITY_CHANGE_SIGNAL, self, "on_gravity_change")

func on_gravity_change(gravityStatus):
	set_mode(gravityStatus)
	
func _physics_process(delta):
	startPosition = get_start_coord()
	endPosition = get_end_coord()
	#check_active(get_global_mouse_position())
	update()
	
func get_start_coord():
	return rb.to_global(lineSegment.shape.get_a())
	
func get_end_coord():
	return rb.to_global(lineSegment.shape.get_b())
	
func get_coord(startOrEnd): 
	if startOrEnd == ROD_START:
		return get_start_coord()
	if startOrEnd == ROD_END:
		return get_end_coord()
	return null

	
	
func _draw():
	var color = globals.ROD_COLOR
	if bg:
		color = globals.BG_ROD_COLOR
	if hovering:
		draw_line(startPosition, endPosition, color, globals.ROD_THICKNESS+2)
	else:
		draw_line(startPosition, endPosition, color, globals.ROD_THICKNESS)
		
	

func init(startPos, endPos, gravityStatus, is_bg):
	rb = get_node("Body")
	lineSegment = get_node("Body/CollisionShape2D")
	selectableArea = get_node("Body/SelectableArea/CollisionShape2D")

	selectableArea.set_shape(RectangleShape2D.new())
	
	bg = is_bg
	if bg:
		make_this_a_background_rod()
	
	set_mode(gravityStatus) 
	lineSegment.set_shape(lineSegment.get_shape().duplicate(true))
	
	var centerPoint = calcCenterPoint(startPos, endPos)
	var xLen = startPos.x - endPos.x
	var yLen = startPos.y - endPos.y
	var a = Vector2(xLen/2, yLen/2)
	var b = -a
	rb.position = centerPoint
	lineSegment.shape.set_a(a)
	lineSegment.shape.set_b(b)
	
	
	startPosition = startPos
	endPosition = endPos
	
	var length = startPos.distance_to(endPos)
	rb.set_weight(globals.BASE_WEIGHT * length)
	selectableArea.shape.set_extents(Vector2(length/2, globals.ROD_THICKNESS*2))
	#deletableArea.rotation = Vector2.RIGHT.angle()
	var rot = startPos.angle_to_point(endPos)
	selectableArea.rotate(rot)
	
func make_this_a_background_rod():
	
	for layer in globals.PHYS_LAYERS:
		rb.set_collision_layer_bit(globals.PHYS_LAYERS[layer], false)
		rb.set_collision_mask_bit(globals.PHYS_LAYERS[layer], false)
	
	rb.set_collision_layer_bit(globals.PHYS_LAYERS.BG_RODS, false)
	rb.set_collision_mask_bit(globals.PHYS_LAYERS.WORLD, true)

func set_mode(gravityStatus):
	if gravityStatus:
		rb.set_mode(rb.MODE_RIGID)
		#gravity = 98
	else:
		#gravity = 0
		rb.set_mode(rb.MODE_STATIC)

func calcCenterPoint(pos1, pos2):
	return Vector2((pos1.x + pos2.x)/2, (pos1.y + pos2.y)/2)
	
func add_elbow(elbow, idx):
	if idx == ROD_START:
		startElbow = elbow
	if idx == ROD_END:
		endElbow = elbow
		
func get_elbow(idx):
	if idx == ROD_START and startElbow != null:
		return startElbow
	if idx == ROD_END and endElbow != null:
		return endElbow
	return null
	

func delete():
	deleted=true
	for elbow in [startElbow, endElbow]:
		if elbow:
			var idx = elbow.attachedRods.find(self)
			if idx >= 0:
				elbow.remove_rod(self)
			if elbow.rodCount <= 0 and elbow.attachedObj == null:
				elbow.delete()
	get_parent().rodCount -= 1
	self.queue_free()

func _on_SelectableArea_mouse_entered():
	if get_parent().get_parent().state == globals.TOOLS.MOVETOOL:
		hovering=true

func _on_SelectableArea_mouse_exited():
	hovering=false

