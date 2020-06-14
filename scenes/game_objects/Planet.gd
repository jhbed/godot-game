tool
extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
export var radius = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StaticBody2D/CollisionShape2D.shape.set_radius(radius)
	
func _draw() -> void:
	draw_circle_custom(radius)

func draw_circle_custom(radius, maxerror = 0.25):
	
	

	if radius <= 0.0:
		return

	var maxpoints = 1024 # I think this is renderer limit

	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)

	var points = PoolVector2Array([])

	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius)

	draw_colored_polygon(points, Color(1.0, 1.0, 1.0))
	draw_circle($GravityZone.gravity_vec, 50, ColorN("Red"))


func _on_GravityZone_body_entered(body: Node) -> void:
	if body.name == 'PlayerRigid':
		body.gravityZone = $GravityZone
