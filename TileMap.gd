extends TileMap

func _ready():
	pass
	#make_tilemap_circle(Vector2(0, 0), 1000);
	
func make_tilemap_circle(center_position, radius):
	# The right half of the circle:
	var relative_vector = Vector2.ZERO
	for x in range(center_position.x, center_position.x + radius):
		for y in range(center_position.y, center_position.y + radius):
			relative_vector.x = x
			relative_vector.y = y
			# you might be able to skip this check and using relative_vector
			# entirely, depending on the radius. Hm...
			if (relative_vector.length() < radius):
				var tile_id
				if relative_vector.length() - radius > -1:
					tile_id = 0
				else:
					tile_id = 1
				self.set_cell(x, y, tile_id)
				self.set_cell(-x, y, tile_id)
				self.set_cell(-x, -y, tile_id)
				self.set_cell(x, -y, tile_id)
