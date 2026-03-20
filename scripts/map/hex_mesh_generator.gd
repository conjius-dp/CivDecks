class_name HexMeshGenerator


static func create_hex_mesh(height: float = 0.1) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var top_y := height * 0.5
	var bot_y := -height * 0.5

	# Top face — 6 triangles fanning from center (CCW winding)
	for i in range(6):
		var c0 := HexUtil.hex_corner_offset(i)
		var c1 := HexUtil.hex_corner_offset((i + 1) % 6)
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.5, 0.5))
		st.add_vertex(Vector3(0.0, top_y, 0.0))
		st.set_uv(_hex_uv(c0))
		st.add_vertex(Vector3(c0.x, top_y, c0.z))
		st.set_uv(_hex_uv(c1))
		st.add_vertex(Vector3(c1.x, top_y, c1.z))

	# Side faces — 6 quads (12 triangles)
	for i in range(6):
		var c0 := HexUtil.hex_corner_offset(i)
		var c1 := HexUtil.hex_corner_offset((i + 1) % 6)
		var side_normal := Vector3((c0.x + c1.x) * 0.5, 0.0, (c0.z + c1.z) * 0.5).normalized()

		st.set_normal(side_normal)
		st.add_vertex(Vector3(c0.x, top_y, c0.z))
		st.add_vertex(Vector3(c0.x, bot_y, c0.z))
		st.add_vertex(Vector3(c1.x, bot_y, c1.z))

		st.set_normal(side_normal)
		st.add_vertex(Vector3(c0.x, top_y, c0.z))
		st.add_vertex(Vector3(c1.x, bot_y, c1.z))
		st.add_vertex(Vector3(c1.x, top_y, c1.z))

	return st.commit()


static func create_hex_collision_shape(height: float = 0.1) -> ConvexPolygonShape3D:
	var points: PackedVector3Array = []
	var top_y := height * 0.5
	var bot_y := -height * 0.5
	for i in range(6):
		var c := HexUtil.hex_corner_offset(i)
		points.append(Vector3(c.x, top_y, c.z))
		points.append(Vector3(c.x, bot_y, c.z))
	var shape := ConvexPolygonShape3D.new()
	shape.points = points
	return shape


static func create_hex_outline_mesh(thickness: float = 0.08) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var y := 0.0
	for i in range(6):
		var c0 := HexUtil.hex_corner_offset(i)
		var c1 := HexUtil.hex_corner_offset((i + 1) % 6)

		var dir0 := c0.normalized()
		var dir1 := c1.normalized()
		var inner0 := c0 - dir0 * thickness
		var inner1 := c1 - dir1 * thickness

		# Quad: outer0, outer1, inner1, inner0 (two triangles, CCW)
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(inner0.x, y, inner0.z))
		st.add_vertex(Vector3(c0.x, y, c0.z))
		st.add_vertex(Vector3(c1.x, y, c1.z))

		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(inner0.x, y, inner0.z))
		st.add_vertex(Vector3(c1.x, y, c1.z))
		st.add_vertex(Vector3(inner1.x, y, inner1.z))

	return st.commit()


static func _hex_uv(corner: Vector3) -> Vector2:
	var u := 0.5 + corner.x / (2.0 * HexUtil.HEX_SIZE)
	var v := 0.5 + corner.z / (2.0 * HexUtil.HEX_SIZE)
	return Vector2(u, v)
