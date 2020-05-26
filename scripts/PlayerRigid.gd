extends RigidBody2D

const MAX_ZOOM = 1.40
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

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.is_pressed():
		
		if event.button_index == BUTTON_WHEEL_UP:
			zoom(1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom(-1)


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	var is_on_ground := state.get_contact_count() > 0 and int(state.get_contact_collider_position(0).y) >= int(global_position.y)
	
	var move_direction := get_move_direction()
	
	if abs(move_direction.x - _direction) == 2:
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		_direction = move_direction.x
	
	match _state:
		IDLE:
			$AnimatedSprite.play("idle")
			if move_direction.x:
				change_state(RUN)
			elif is_on_ground and Input.is_action_just_pressed("ui_up"):
				apply_central_impulse(Vector2.UP * jump_force)
		RUN:
			if is_on_ground:
				$AnimatedSprite.play("run")
			if not move_direction.x:
				change_state(IDLE)
			elif state.get_contact_count() == 0:
				change_state(AIR)
			elif is_on_ground and Input.is_action_just_pressed("ui_up"):
				apply_central_impulse(Vector2.UP * jump_force)
				change_state(AIR)
				$AnimatedSprite.play("jump")
			else:
				state.linear_velocity.x = move_direction.x * move_speed
				
		AIR:
			if move_direction.x:
				state.linear_velocity.x += move_direction.x * air_speed
			if is_on_ground and just_aired_timer.is_stopped():
				change_state(IDLE)
				
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
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0
	)
	
func zoom(amount):
	var zoomFactor := 0.01
	var origZoom : Vector2 = $Camera2D.get_zoom()
	var appliedAmount = origZoom.x + amount * zoomFactor
	if appliedAmount > MAX_ZOOM or appliedAmount < MIN_ZOOM:
		return
	var newZoom := Vector2(appliedAmount, appliedAmount)
	$Camera2D.set_zoom(newZoom)
	$Camera2D.offset.y -= amount*2
	#get_tree().get_root().get_node("Main/Background").position.y -= amount*1000
	
