extends Node


export(NodePath) var mesh_instance = "scout_3d_01/Cube"
export(NodePath) var output = "CanvasLayer/Control/TextureRect"
export(Texture) var original_texture = null
export(Vector2) var new_texture_size = Vector2(1024,1024)

onready var _mesh_instance : MeshInstance = get_node(mesh_instance)
onready var _output : TextureRect = get_node(output)

var _original_texture_size : Vector2

func _ready():
	_original_texture_size = original_texture.get_size()
	call_deferred("remap")

# https://stackoverflow.com/questions/18844000/transfer-coordinates-from-one-triangle-to-another-triangle
func remap():
	# need new and old UVs
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()
	var new_texture_colors : Array = []
	new_texture_colors.resize(new_texture_size.x * new_texture_size.y * 4)
	
	var orig_im : Image = original_texture.get_data()
	orig_im.lock()
	
	var mesh : Mesh = _mesh_instance.mesh
	
	print("surface count = " + str(mesh.get_surface_count()))
	for surface_id in mesh.get_surface_count():
		var vertex_data : Array = mesh.surface_get_arrays(surface_id)
		var uvs : PoolVector2Array = vertex_data[Mesh.ARRAY_TEX_UV]
		var uvs2 : PoolVector2Array = vertex_data[Mesh.ARRAY_TEX_UV2]
		var vertices : PoolVector3Array = vertex_data[Mesh.ARRAY_VERTEX]
		var indices : PoolIntArray = vertex_data[Mesh.ARRAY_INDEX]
		
		var step_u : float = 1.0 / new_texture_size.x
		var step_v : float = 1.0 / new_texture_size.y

		var tmp_color = Color(1.0, 0.0, 0.0, 1.0)
		for i in range(0, indices.size(), 3):
			var vertice0 : Vector3 = vertices[indices[i]]
			var uv0 : Vector2 = uvs[indices[i]]
			var uv_dest0 : Vector2 = uvs2[indices[i]]
			var vertice1 : Vector3 = vertices[indices[i+1]]
			var uv1 : Vector2 = uvs[indices[i+1]]
			var uv_dest1 : Vector2 = uvs2[indices[i+1]]
			var vertice2 : Vector3 = vertices[indices[i+2]]
			var uv2 : Vector2 = uvs[indices[i+2]]
			var uv_dest2 : Vector2 = uvs2[indices[i+2]]
			

			var xa1 = uv_dest0.x
			var ya1 = uv_dest0.y
			var xa2 = uv_dest1.x
			var ya2 = uv_dest1.y
			var xa3 = uv_dest2.x
			var ya3 = uv_dest2.y
			var xb1 = uv0.x
			var yb1 = uv0.y
			var xb2 = uv1.x
			var yb2 = uv1.y
			var xb3 = uv2.x
			var yb3 = uv2.y
			
			var inv_row0 = Vector3(ya2-ya3, -(xa2-xa3), (xa2*ya3-xa3*ya2))
			var inv_row1 = Vector3(-(-ya3+ya1), (-xa3+xa1), -(xa1*ya3-ya1*xa3))
			var inv_row2 = Vector3((-ya2+ya1), -(-xa2+xa1), (xa1*ya2-ya1*xa2))
			var det = xa2*ya3-xa3*ya2-ya1*xa2+ya1*xa3+xa1*ya2-xa1*ya3
			inv_row0 = inv_row0 / det
			inv_row1 = inv_row1 / det
			inv_row2 = inv_row2 / det
			
			# m = a * inv(b)
			var m_row0 = Vector3(xb1*inv_row0.x+xb2*inv_row1.x+xb3*inv_row2.x, xb1*inv_row0.y+xb2*inv_row1.y+xb3*inv_row2.y, xb1*inv_row0.z+xb2*inv_row1.z+xb3*inv_row2.z)
			var m_row1 = Vector3(yb1*inv_row0.x+yb2*inv_row1.x+yb3*inv_row2.x, yb1*inv_row0.y+yb2*inv_row1.y+yb3*inv_row2.y, yb1*inv_row0.z+yb2*inv_row1.z+yb3*inv_row2.z)
			var m_row2 = Vector3(1.0*inv_row0.x+1.0*inv_row1.x+1.0*inv_row2.x, 1.0*inv_row0.y+1.0*inv_row1.y+1.0*inv_row2.y, 1.0*inv_row0.z+1.0*inv_row1.z+1.0*inv_row2.z)
			
			#var calculated_orig = Vector3(m_row0.x*uv_dest0.x+m_row0.y*uv_dest0.y+m_row0.z*1.0, m_row1.x*uv_dest0.x+m_row1.y*uv_dest0.y+m_row1.z*1.0, m_row2.x*uv_dest0.x+m_row2.y*uv_dest0.y+m_row2.z*1.0)
			
#			print("triangle")
#			print("%.3f, %.3f, %.3f, %.3f, %.3f, %.3f" % [uv0.x, uv0.y, uv_dest0.x, uv_dest0.y, calculated_orig.x, calculated_orig.y])
#			print("%.3f, %.3f, %.3f, %.3f, %.3f, %.3f" % [uv1.x, uv1.y, uv_dest1.x, uv_dest1.y, calculated_orig.x, calculated_orig.y])
#			print("%.3f, %.3f, %.3f, %.3f, %.3f, %.3f" % [uv2.x, uv2.y, uv_dest2.x, uv_dest2.y, calculated_orig.x, calculated_orig.y])
			
			
			var min_x = min(min(uv_dest0.x, uv_dest1.x), uv_dest2.x)
			var max_x = max(max(uv_dest0.x, uv_dest1.x), uv_dest2.x)
			var min_y = min(min(uv_dest0.y, uv_dest1.y), uv_dest2.y)
			var max_y = max(max(uv_dest0.y, uv_dest1.y), uv_dest2.y)
			
			var cur_x = min_x
			var cur_y = min_y
			#print("orig u, orig v, dest u, dest v")
			#print("%.3f, %.3f, %.3f, %.3f" % [xb1, yb1, xa1, ya1])
			#print("%.3f, %.3f, %.3f, %.3f" % [xb2, yb2, xa2, ya2])
			#print("%.3f, %.3f, %.3f, %.3f" % [xb3, yb3, xa3, ya3])
			
#			var vp_size = self.get_viewport().size
#			if get_viewport().is_size_override_enabled():
#				vp_size = get_viewport().get_size_override()
#			var r = get_node("CanvasLayer/Control")
#			var n = Polygon2D.new()
#			var points := PoolVector2Array()
#			points.push_back(Vector2(xa1 * vp_size.x, ya1 * vp_size.y))
#			points.push_back(Vector2(xa2 * vp_size.x, ya2 * vp_size.y))
#			points.push_back(Vector2(xa3 * vp_size.x, ya3 * vp_size.y))
#			n.polygon = points
#			n.color = tmp_color
#			r.add_child(n)
			
			
			
			#print("orig x, orig y, dest x, dest y, red, green, blue, alpha")
			while cur_x <= max_x:
				cur_y = min_y
				while cur_y <= max_y:
					if point_in_triangle(uv_dest0, uv_dest1, uv_dest2, Vector2(cur_x, cur_y)) and cur_x < 1.0 and cur_y < 1.0:
						var array_x = int(cur_x * new_texture_size.x)
						var array_y = int(cur_y * new_texture_size.y)
						var calculated_orig = Vector3(m_row0.x*cur_x+m_row0.y*cur_y+m_row0.z*1.0, m_row1.x*cur_x+m_row1.y*cur_y+m_row1.z*1.0, m_row2.x*cur_x+m_row2.y*cur_y+m_row2.z*1.0)
						var orig_x = int(calculated_orig.x * _original_texture_size.x)
						var orig_y = int(calculated_orig.y * _original_texture_size.y)
						var orig_col = orig_im.get_pixel(orig_x, orig_y)
						new_texture_colors[(array_y*new_texture_size.x*4) + (array_x*4)+0] = orig_col.r8
						new_texture_colors[(array_y*new_texture_size.x*4) + (array_x*4)+1] = orig_col.g8
						new_texture_colors[(array_y*new_texture_size.x*4) + (array_x*4)+2] = orig_col.b8
						new_texture_colors[(array_y*new_texture_size.x*4) + (array_x*4)+3] = orig_col.a8
						#print(tmp_color.r8)
#						new_texture_colors[(array_y*new_texture_size.x*4) + (array_x*4)+0] = tmp_color.r8
#						new_texture_colors[(array_y*new_texture_size.x*4) + (array_x*4)+1] = tmp_color.g8
#						new_texture_colors[(array_y*new_texture_size.x*4) + (array_x*4)+2] = tmp_color.b8
#						new_texture_colors[(array_y*new_texture_size.x*4) + (array_x*4)+3] = tmp_color.a8
						
						#print("%d, %d, %d, %d, %d, %d, %d, %d" % [orig_x, orig_y, array_x, array_y, orig_col.r8, orig_col.g8, orig_col.b8, orig_col.a8])
						
					cur_y += step_v
				cur_x += step_u
				
			if tmp_color.r8 == 255:
				tmp_color.b8 = 255
				tmp_color.r8 = 0
			elif tmp_color.b8 == 255:
				tmp_color.b8 = 0
				tmp_color.g8 = 255
			elif tmp_color.g8 == 255:
				tmp_color.g8 = 0
				tmp_color.r8 = 255
				
			
			
	orig_im.unlock()
	dynImage.create_from_data(new_texture_size.x, new_texture_size.y,false,Image.FORMAT_RGBA8, new_texture_colors)
	imageTexture.create_from_image(dynImage)
	imageTexture.resource_name = "The created texture!"
	
	#imageTexture = load("res://data/private/textures/space-sprite.png")
	var cur_datetime : Dictionary = OS.get_datetime()
	var save_file_path = "user://screenshot-%s%s%s-%s%s%s.png" % [cur_datetime["year"], cur_datetime["month"], cur_datetime["day"], cur_datetime["hour"], cur_datetime["minute"], cur_datetime["second"]]
	var image = imageTexture.get_data()
	image.flip_y()
	image.save_png(save_file_path)
	
	_output.texture = imageTexture
	print("DONE")
			
			
			
			
func point_in_triangle(p1 : Vector2, p2 : Vector2, p3 : Vector2, p : Vector2):
	var denom : float = ((p2.y - p3.y)*(p1.x-p3.x)+(p3.x-p2.x)*(p1.y-p3.y))
	if abs(denom) < 0.000001:
		return false
	var a = ((p2.y-p3.y)*(p.x-p3.x)+(p3.x-p2.x)*(p.y-p3.y)) / denom
	var b = ((p3.y-p1.y)*(p.x-p3.x)+(p1.x-p3.x)*(p.y-p3.y)) / denom
	var c = 1 - a - b
	
	return 0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1
		
#	_arrays[Mesh.ARRAY_VERTEX] = vertex_array
#	_arrays[Mesh.ARRAY_NORMAL] = normal_array
#	_arrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array(_uv_array)
#	_arrays[Mesh.ARRAY_INDEX] = index_array
