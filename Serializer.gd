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
		
	var obj = {
		'id' : currentObjId,
		'obj_type' : globals.TOOLS.WHEELTOOL,
		'position' : wheel.rb.global_transform.origin - startPos,
		'outer_elbows' : elbow_ids,
	}
	objs[currentObjId] = obj
	return currentObjId
	
func serialize_motor(motor):
	return {
		'id' : currentObjId,
		'obj_type' : globals.TOOLS.MOTORTOOL,
		'position' : motor.rb.global_transform.origin - startPos
	}
