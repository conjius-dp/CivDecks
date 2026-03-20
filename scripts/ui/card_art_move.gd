extends Control

var base_color: Color = Color(0.3, 0.69, 0.29)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var ground_y := h * 0.72

	# Sky / canopy — dark green gradient at top
	var canopy_color := Color(0.1, 0.28, 0.08)
	draw_rect(Rect2(0, 0, w, ground_y * 0.3), canopy_color)

	# Dappled light patches in canopy
	var light_green := Color(0.18, 0.4, 0.12, 0.6)
	draw_circle(Vector2(w * 0.2, h * 0.12), 8.0, light_green)
	draw_circle(Vector2(w * 0.6, h * 0.08), 6.0, light_green)
	draw_circle(Vector2(w * 0.85, h * 0.15), 7.0, light_green)

	# Background trees
	_draw_tree(Vector2(w * 0.08, ground_y), 10.0, 28.0, Color(0.12, 0.32, 0.1))
	_draw_tree(Vector2(w * 0.28, ground_y), 8.0, 22.0, Color(0.14, 0.35, 0.11))
	_draw_tree(Vector2(w * 0.72, ground_y), 9.0, 25.0, Color(0.11, 0.3, 0.09))
	_draw_tree(Vector2(w * 0.92, ground_y), 11.0, 30.0, Color(0.13, 0.33, 0.1))

	# Mid-ground tree
	_draw_tree(Vector2(w * 0.5, ground_y), 12.0, 32.0, Color(0.15, 0.38, 0.12))

	# Forest floor
	var floor_color := Color(0.25, 0.18, 0.1)
	draw_rect(Rect2(0, ground_y, w, h - ground_y), floor_color)

	# Fallen leaves / debris on ground
	var leaf_color := Color(0.35, 0.25, 0.12, 0.7)
	for i in range(8):
		var lx := w * (0.1 + 0.1 * i)
		var ly := ground_y + (h - ground_y) * 0.3 + sin(i * 2.3) * 3.0
		draw_circle(Vector2(lx, ly), 2.0, leaf_color)

	# Path / dirt trail
	var path_color := Color(0.3, 0.22, 0.12)
	draw_rect(Rect2(0, ground_y + 2, w, (h - ground_y) * 0.5), path_color)

	# Left boot (back foot, slightly behind)
	_draw_boot(Vector2(w * 0.25, ground_y + 1), 0.85, -0.05)

	# Right boot (front foot, stepping forward)
	_draw_boot(Vector2(w * 0.58, ground_y - 2), 1.0, 0.12)

	# Dust particles behind back boot
	var dust := Color(0.5, 0.4, 0.3, 0.3)
	draw_circle(Vector2(w * 0.15, ground_y + 4), 3.0, dust)
	draw_circle(Vector2(w * 0.1, ground_y + 2), 2.0, Color(dust, 0.2))
	draw_circle(Vector2(w * 0.2, ground_y + 6), 2.5, Color(dust, 0.25))


func _draw_boot(pos: Vector2, s: float, tilt: float) -> void:
	var sole_color := Color(0.15, 0.1, 0.06)
	var leather := Color(0.35, 0.22, 0.12)
	var leather_dark := Color(0.25, 0.15, 0.08)
	var lace_color := Color(0.2, 0.15, 0.08)

	# Boot sole — thick bottom
	var sole: PackedVector2Array = [
		pos + Vector2(-6, 12) * s,
		pos + Vector2(16, 12) * s,
		pos + Vector2(18, 9) * s,
		pos + Vector2(-5, 9) * s,
	]
	_rotate_points(sole, pos, tilt)
	draw_colored_polygon(sole, sole_color)

	# Boot body — main shaft
	var body: PackedVector2Array = [
		pos + Vector2(-5, 9) * s,
		pos + Vector2(14, 9) * s,
		pos + Vector2(12, -14) * s,
		pos + Vector2(-3, -14) * s,
	]
	_rotate_points(body, pos, tilt)
	draw_colored_polygon(body, leather)

	# Toe cap — rounded front
	var toe: PackedVector2Array = [
		pos + Vector2(14, 9) * s,
		pos + Vector2(18, 9) * s,
		pos + Vector2(19, 5) * s,
		pos + Vector2(16, 2) * s,
		pos + Vector2(13, 2) * s,
	]
	_rotate_points(toe, pos, tilt)
	draw_colored_polygon(toe, leather_dark)

	# Boot top rim
	var rim: PackedVector2Array = [
		pos + Vector2(-4, -14) * s,
		pos + Vector2(13, -14) * s,
		pos + Vector2(13, -17) * s,
		pos + Vector2(-4, -17) * s,
	]
	_rotate_points(rim, pos, tilt)
	draw_colored_polygon(rim, leather_dark)

	# Lace details — horizontal lines
	for i in range(3):
		var ly := -4.0 - i * 3.5
		var p1 := pos + Vector2(0, ly) * s
		var p2 := pos + Vector2(9, ly) * s
		var c := cos(tilt)
		var sn := sin(tilt)
		var r1 := pos + Vector2(
			(p1.x - pos.x) * c - (p1.y - pos.y) * sn,
			(p1.x - pos.x) * sn + (p1.y - pos.y) * c
		)
		var r2 := pos + Vector2(
			(p2.x - pos.x) * c - (p2.y - pos.y) * sn,
			(p2.x - pos.x) * sn + (p2.y - pos.y) * c
		)
		draw_line(r1, r2, lace_color, 1.0)


func _draw_tree(base: Vector2, trunk_w: float, tree_h: float, color: Color) -> void:
	var trunk_color := Color(0.3, 0.2, 0.1)
	# Trunk
	draw_rect(
		Rect2(base.x - trunk_w * 0.15, base.y - tree_h * 0.3, trunk_w * 0.3, tree_h * 0.35),
		trunk_color,
	)
	# Canopy layers
	for i in range(3):
		var layer_y := base.y - tree_h * (0.3 + 0.22 * i)
		var layer_w := trunk_w * (1.4 - 0.25 * i)
		var pts: PackedVector2Array = [
			Vector2(base.x - layer_w, layer_y),
			Vector2(base.x + layer_w, layer_y),
			Vector2(base.x, layer_y - tree_h * 0.3),
		]
		var shade: Color = color.darkened(0.1 * i)
		draw_colored_polygon(pts, shade)


func _rotate_points(
	points: PackedVector2Array, pivot: Vector2, angle: float,
) -> void:
	var c := cos(angle)
	var s := sin(angle)
	for i in range(points.size()):
		var p := points[i] - pivot
		points[i] = pivot + Vector2(p.x * c - p.y * s, p.x * s + p.y * c)
