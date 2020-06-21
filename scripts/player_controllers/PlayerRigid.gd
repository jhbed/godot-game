extends RigidBody2D

var gravityZone = null

const MAX_ZOOM = 2.0
const MIN_ZOOM = 0.55

enum {
	IDLE, RUN, AIR
}

onready var just_aired_timer : Timer = $Timer
onready var _transitions = {
	IDLE: [RUN, AIR],
	RUN: [IDLE, AIR],
	AIR: [IDLE]
}

const FLOOR_NORMAL := Vector2.UP

export var move_speed:= 60.0
export var air_speed := 0.5
export var jump_force := 150.0

var _state: int = IDLE
var _direction = 1

func _physics_process(delta: float) -> void:
	var rot = get_physics_rotation()
	
	#get_node("Background2").rotate(get_rotation() - rot)
	set_rotation(rot)

func _ready():
	pass
	#rotate(PI)
	
func get_physics_rotation():
	return Vector2.DOWN.angle_to(get_gravity_vector())

func get_gravity_vector():
	if gravityZone == null:
		return Vector2.DOWN
	return (gravityZone.get_global_transform().origin - 
			get_global_transform().origin).normalized()
			
func ground_check(state):
	var is_on_ground
	if state.get_contact_count() > 0:
		var down = get_gravity_vector()
		var rot = down.angle_to(Vector2.DOWN)
		
		is_on_ground = int(state.get_contact_collider_position(0).rotated(rot).y) >= int(global_position.rotated(rot).y)
	else:
		is_on_ground=false
	return is_on_ground
	
	

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.is_pressed():
		
		if event.button_index == BUTTON_WHEEL_UP:
			zoom(1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom(-1)
			
	if event is InputEventKey and event.is_pressed():
		
		if event.scancode == KEY_I:
			zoom(1)
		if event.scancode == KEY_O:
			zoom(-1)


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	
	var is_on_ground = ground_check(state)
	var move_direction := get_move_direction()
	
	match _state:
		IDLE:
			$AnimatedSprite.play("idle")
			if move_direction.x:
				change_state(RUN)
			elif is_on_ground and Input.is_action_just_pressed("ui_up"):
				jump()
		RUN:
			if is_on_ground:
				$AnimatedSprite.play("run")
			if not move_direction.x:
				change_state(IDLE)
			elif state.get_contact_count() == 0:
				change_state(AIR)
			elif is_on_ground and Input.is_action_just_pressed("ui_up"):
				jump()
				change_state(AIR)
				$AnimatedSprite.play("jump")
			else:
				#state.linear_velocity = move(state, move_direction)
				state.linear_velocity = get_move_direction() * move_speed
				#state.linear_velocity.x = move_direction.x * move_speed
				
		AIR:
			if move_direction.x:
				state.linear_velocity.x += move_direction.x * air_speed
			if is_on_ground and just_aired_timer.is_stopped():
				change_state(IDLE)

func jump():
	apply_central_impulse(-get_gravity_vector() * jump_force)
	
func move(state, direction):
	var baseDir = state.linear_velocity
	baseDir.x = direction.x * move_speed
	print(rotation)
	return baseDir.rotated(rotation)
	
		
func change_state(target_state: int) -> void:
	if not target_state in _transitions[_state]:
		return
	_state = target_state
	enter_state()

func enter_state() -> void:
	match _state:
		IDLE:
			linear_velocity.x = 0
		AIR:
			just_aired_timer.start()
		_:
			return
				
	
func get_move_direction() -> Vector2:
	var dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0
	)
	if abs(dir.x - _direction) == 2:
		_direction = dir.x
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	return dir.rotated(rotation)
	
func zoom(amount):
	var zoomFactor := 0.05
	var origZoom : Vector2 = $Camera2D.get_zoom()
	var appliedAmount = origZoom.x + amount * zoomFactor
	if appliedAmount > MAX_ZOOM or appliedAmount < MIN_ZOOM:
		return
	var newZoom := Vector2(appliedAmount, appliedAmount)
	$Camera2D.set_zoom(newZoom)
	$Camera2D.offset.y -= amount*2
	#get_tree().get_root().get_node("Main/Background").position.y -= amount*1000
	
