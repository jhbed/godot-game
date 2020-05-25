extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const GRAVITY = 4
const SPEED = 100
const JUMP_HEIGHT = -100

var motion = Vector2()
var canJump = true
var walking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	
	#var col = $GroundRay.is_colliding()
	var floorvel = Vector2(0,0)
	var colliding = is_on_floor()
	
	if not colliding:
		motion.y += GRAVITY
	else:
		var xvel
		if Input.is_action_pressed("ui_right"):
			$AnimatedSprite.flip_h = false
			$AnimatedSprite.play("run")
			walking = true
			xvel = 1
		elif Input.is_action_pressed("ui_left"):
			$AnimatedSprite.flip_h = true
			$AnimatedSprite.play("run")
			walking = true
			xvel=-1
		else:
			$AnimatedSprite.play("idle")
			xvel=0
			walking = false
		xvel *= SPEED
		motion.x = xvel
		
	if colliding:
		if Input.is_action_pressed("ui_up") and canJump:
			canJump = false
			motion.y = JUMP_HEIGHT
			
		if get_floor_velocity().y != 0:
			motion.y = 0

		
	elif not colliding and not canJump:
		$AnimatedSprite.play("jump")
		
	if Input.is_action_just_released("ui_up"):
		canJump = true
	
	#motion = move_and_slide(motion, Vector2.UP, false, 4, PI/4, false)
	var snap = Vector2.DOWN * 16 if colliding else Vector2.ZERO
	
	#print(motion)
	
	motion = move_and_slide_with_snap(motion, snap, Vector2.UP, false, 4, PI/4, false)
	#motion = move_and_slide(motion, Vector2.UP)
	#motion = move_and_slide(motion, Vector2.UP, false, 4, PI/4, false)
	
#func _input(event):
#	if event is InputEventKey:
#		if event.is_action_pressed("ui_right"):
#			moving = true
#			motion.x = SPEED
#			$AnimatedSprite.flip_h=false
#			$AnimatedSprite.play("run")
#		elif event.is_action_pressed("ui_left"):
#			moving = true
#			motion.x = -SPEED
#			$AnimatedSprite.flip_h=true
#			$AnimatedSprite.play("run")
#
#		if (event.is_action_released("ui_right") or event.is_action_released("ui_left")):
#			moving = false
#			$AnimatedSprite.play("idle")
#			motion.x = 0
#
#		if is_on_floor():
#			if event.scancode == KEY_SPACE:
#				motion.y = JUMP_HEIGHT
#		else:
#			$AnimatedSprite.play("jump")
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
