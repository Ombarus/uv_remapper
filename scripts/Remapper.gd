extends Node

export(NodePath) var mesh_instance = "scout_3d_01/Cube"
export(NodePath) var output = "CanvasLayer/Control/TextureRect"
export(NodePath) var immediate_geometry = "Viewport/ImmediateGeometry"
export(NodePath) var viewport = "Viewport"
export(Texture) var original_texture = null
export(Vector2) var new_texture_size = Vector2(1024,1024)

onready var _mesh_instance : MeshInstance = get_node(mesh_instance)
onready var _output : TextureRect = get_node(output)
onready var _immediate_geometry : ImmediateGeometry = get_node(immediate_geometry)
onready var _viewport : Viewport = get_node(viewport)

func _ready():
	call_deferred("remap")

# Helper function
# Adds a vertex with coordinate from uv_target and uv coordinate from uv_source
# vertext_idx is translated using indices array
func _add_vertex_from_target(
		indices : PoolIntArray,
		uv_source : PoolVector2Array,
		uv_target : PoolVector2Array,
		vertex_idx : int):
	
	var idx_from_indices = indices[vertex_idx]
	
	var vert_coord := uv_target[idx_from_indices]
	var vert_3d := Vector3(vert_coord.x, vert_coord.y, 0.0)
	
	_immediate_geometry.set_uv(uv_source[idx_from_indices])
	_immediate_geometry.add_vertex(vert_3d)
	

# Main idea is to generate a mesh representation of second uv channel
# and set its uvs as uv first set,
# then just render it with GPU using source texture
func remap():
	
	var mesh : Mesh = _mesh_instance.mesh
	
	print("surface count = " + str(mesh.get_surface_count()))
	for surface_id in mesh.get_surface_count():
		var vertex_data : Array = mesh.surface_get_arrays(surface_id)
		var uvs : PoolVector2Array = vertex_data[Mesh.ARRAY_TEX_UV]
		var uvs2 : PoolVector2Array = vertex_data[Mesh.ARRAY_TEX_UV2]
		var indices : PoolIntArray = vertex_data[Mesh.ARRAY_INDEX]
		
		# For each surface add a bunch of triangles
		_immediate_geometry.begin(Mesh.PRIMITIVE_TRIANGLES, original_texture)
		for i in range(0, indices.size(), 3):
			
			# Generates a single triangle
			for j in range(i, i + 3):
				_add_vertex_from_target(indices, uvs, uvs2, j)
			
		_immediate_geometry.end()
			
	
	print("mesh generated")
	
	# Set viewports texture
	_viewport.size = new_texture_size
	# Update viewport
	_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	
	# Wait for texture to become valid
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var viewport_texture : Texture = _viewport.get_texture() 
	
	print("viewport captured")
	
	var cur_datetime : Dictionary = OS.get_datetime()
	var save_file_path = "user://screenshot-%s_%s_%s-%s_%s_%s.png" % [cur_datetime["year"], cur_datetime["month"], cur_datetime["day"], cur_datetime["hour"], cur_datetime["minute"], cur_datetime["second"]]
	
	var viewport_texture_data = viewport_texture.get_data()
	# Convert just in case
	viewport_texture_data.convert(Image.FORMAT_RGBA8)
	
	viewport_texture_data.save_png(save_file_path)
	
	# Update 2D display
	_output.texture = viewport_texture
	print("DONE")
