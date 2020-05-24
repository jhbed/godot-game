extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const GRAVITY = 9.8
const SPEED = 100
const JUMP_HEIGHT = -200

var motion = Vector2()
var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	motion.y += GRAVITY
	if not moving:
		motion.x = 0
	motion = move_and_slide(motion, Vector2.UP, false, 4, PI/4, false)
	#motion = move_and_slide(motion, Vector2.UP)
	
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_D:
			moving = true
			motion.x = SPEED
			$AnimatedSprite.flip_h=false
			$AnimatedSprite.play("run")
		elif event.scancode == KEY_A:
			moving = true
			motion.x = -SPEED
			$AnimatedSprite.flip_h=true
			$AnimatedSprite.play("run")
			
		if (event.scancode == KEY_D or event.scancode == KEY_A) and !event.is_pressed():
			moving = false
			$AnimatedSprite.play("idle")
			motion.x = 0
		
		if is_on_floor():
			if event.scancode == KEY_SPACE:
				motion.y = JUMP_HEIGHT
		else:
			$AnimatedSprite.play("jump")
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
