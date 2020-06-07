extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var elbows = {}
var objs = {}
var rods = Array()
var currentElbowId = 0
var currentObjId = 0
var traversedRods = {}
var startPos = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func serialize_graph(rb):
	traverse_graph(rb.get_assoc_elbow(), null)
	var elbow_list = Array()
	for elbow in elbows:
		elbow_list.append(elbows[elbow])
	return to_json({
		'elbows' : elbow_list,
		'rods' : rods,
		'objs' : objs
	})


func traverse_graph(elbow, came_from):
	
	if elbows.has(elbow):
		rods.append( [elbows[elbow]['id'], came_from['id']])
		return
	
	var serialized_elbow = serialize_elbow(elbow)		
	elbows[elbow] = serialized_elbow
	
	if came_from:
		rods.append( [serialized_elbow['id'], came_from['id']] )
	
	for rod in elbow.attachedRods:
		
		if not traversedRods.has(rod):

			traversedRods[rod] = 1
			#rods.append( [serialized_elbow['id'], came_from['id']] )
			if rod.startElbow != elbow:
				traverse_graph(rod.startElbow, serialized_elbow)
			
			if rod.endElbow != elbow:
				traverse_graph(rod.endElbow, serialized_elbow)

			
			

func serialize_elbow(elbow, obj_id=null, is_outer=false):
	currentElbowId += 1
	if startPos == null:
		startPos = elbow.hub.global_transform.origin
	
	var pos = elbow.hub.global_transform.origin - startPos
	var elbId = currentElbowId
	return {
		"id" : elbId,
		"pos_x" : pos.x,
		"pos_y" : pos.y,
		"attached_obj" : serialize_obj(elbow.attachedObj) if obj_id==null else obj_id,
		"is_outer" : is_outer
	}
	
func serialize_obj(obj):
	
	if obj == null:
		return -1
		
	currentObjId += 1
	if obj.obj_type == globals.TOOLS.WHEELTOOL:
		return serialize_wheel(obj)
	
	if obj.obj_type == globals.TOOLS.MOTORTOOL:
		return serialize_motor(obj)

	
func serialize_wheel(wheel):
	var elbow_ids = Array()
	for elb in wheel.get_outer_elbows():
		var serialized_elb = serialize_elbow(elb, currentObjId, true)
		elbows[elb] = serialized_elb
		elbow_ids.append(serialized_elb['id'])
	
	var pos = wheel.rb.global_transform.origin - startPos
	var obj = {
		'id' : currentObjId,
		'obj_type' : globals.TOOLS.WHEELTOOL,
		'pos_x' : pos.x,
		'pos_y' : pos.y,
		'outer_elbows' : elbow_ids,
	}
	objs[currentObjId] = obj
	return currentObjId
	
func serialize_motor(motor):
	var pos = motor.rb.global_transform.origin - startPos
	return {
		'id' : currentObjId,
		'obj_type' : globals.TOOLS.MOTORTOOL,
		'pos_x' : pos.x,
		'pos_y' : pos.y 
	}
	
func deserialize_at_pos(filename, pos, multiTool):
	
	var file = File.new()
	
	if not file.file_exists(filename):
		return # Error! We don't have a save to load.
	
	file.open("user://savegame.save", File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	
	var elbow_dict = {}
	var obj_dict = {}
	
	for selbow in data.elbows:
		
		if selbow.is_outer:
			continue
		
		var elbowPos = Vector2(selbow.pos_x, selbow.pos_y)
		var elbow = multiTool.init_new_elbow(pos + elbowPos)
		
		if selbow.attached_obj != -1 and selbow.is_outer == false:
			var obj_id : int = selbow.attached_obj
			var obj = multiTool.init_new_object_on_elbow(data.objs[String(obj_id)].obj_type, elbow)
			
			if obj.obj_type == globals.TOOLS.WHEELTOOL:
				var sobj = data.objs[String(obj_id)]
				elbow_dict[sobj['outer_elbows'][0]] = obj.elbowNorth
				elbow_dict[sobj['outer_elbows'][1]] = obj.elbowEast
				elbow_dict[sobj['outer_elbows'][2]] = obj.elbowSouth
				elbow_dict[sobj['outer_elbows'][3]] = obj.elbowWest
		
		elbow_dict[selbow['id']] = elbow
	
	print(data.rods)	
	for rod_coords in data.rods:
		var rod = multiTool.init_new_rod_on_elbows(elbow_dict[rod_coords[0]], elbow_dict[rod_coords[1]])
		
		
