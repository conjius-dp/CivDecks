extends Control

var base_color: Color = Color(0.3, 0.69, 0.29)


func _draw() -> void:
	var w := size.x
	var h := size.y
	var cx := w * 0.5
	var cy := h * 0.5

	# Left boot (back foot, slightly tilted back)
	_draw_boot(Vector2(cx - 14, cy + 6), 1.0, -0.1)

	# Right boot (front foot, stepping forward, tilted forward)
	_draw_boot(Vector2(cx + 14, cy + 2), 1.0, 0.15)


func _draw_boot(pos: Vector2, s: float, tilt: float) -> void:
	var sole_dark := Color(0.12, 0.08, 0.04)
	var sole_mid := Color(0.2, 0.14, 0.08)
	var leather := Color(0.32, 0.26, 0.18)
	var leather_hi := Color(0.4, 0.32, 0.22)
	var leather_dark := Color(0.22, 0.16, 0.1)
	var lace_color := Color(0.18, 0.14, 0.08)
	var eyelet := Color(0.5, 0.45, 0.35)

	# Sole tread
	var tread: PackedVector2Array = [
		pos + Vector2(-7, 14) * s,
		pos + Vector2(17, 14) * s,
		pos + Vector2(19, 11) * s,
		pos + Vector2(-6, 11) * s,
	]
	_rotate_points(tread, pos, tilt)
	draw_colored_polygon(tread, sole_dark)

	# Sole mid
	var sole: PackedVector2Array = [
		pos + Vector2(-6, 11) * s,
		pos + Vector2(18, 11) * s,
		pos + Vector2(17, 8) * s,
		pos + Vector2(-5, 8) * s,
	]
	_rotate_points(sole, pos, tilt)
	draw_colored_polygon(sole, sole_mid)

	# Main shaft
	var shaft: PackedVector2Array = [
		pos + Vector2(-5, 8) * s,
		pos + Vector2(13, 8) * s,
		pos + Vector2(11, -18) * s,
		pos + Vector2(-3, -18) * s,
	]
	_rotate_points(shaft, pos, tilt)
	draw_colored_polygon(shaft, leather)

	# Shaft highlight strip (left side shine)
	var shine: PackedVector2Array = [
		pos + Vector2(-4, 7) * s,
		pos + Vector2(-1, 7) * s,
		pos + Vector2(-1, -16) * s,
		pos + Vector2(-3, -16) * s,
	]
	_rotate_points(shine, pos, tilt)
	draw_colored_polygon(shine, leather_hi)

	# Toe box
	var toe: PackedVector2Array = [
		pos + Vector2(13, 8) * s,
		pos + Vector2(18, 8) * s,
		pos + Vector2(19, 4) * s,
		pos + Vector2(17, 0) * s,
		pos + Vector2(13, 0) * s,
	]
	_rotate_points(toe, pos, tilt)
	draw_colored_polygon(toe, leather_dark)

	# Toe welt line
	var welt_p1 := _rot(pos + Vector2(13, 1) * s, pos, tilt)
	var welt_p2 := _rot(pos + Vector2(18, 5) * s, pos, tilt)
	draw_line(welt_p1, welt_p2, sole_mid, 1.0)

	# Top collar
	var collar: PackedVector2Array = [
		pos + Vector2(-4, -18) * s,
		pos + Vector2(12, -18) * s,
		pos + Vector2(12, -21) * s,
		pos + Vector2(-4, -21) * s,
	]
	_rotate_points(collar, pos, tilt)
	draw_colored_polygon(collar, leather_dark)

	# Lace eyelets and laces
	for i in range(4):
		var ly := -2.0 - i * 4.0
		var el := _rot(pos + Vector2(1, ly) * s, pos, tilt)
		draw_circle(el, 1.2 * s, eyelet)
		var er := _rot(pos + Vector2(9, ly) * s, pos, tilt)
		draw_circle(er, 1.2 * s, eyelet)
		var ll := _rot(pos + Vector2(2, ly) * s, pos, tilt)
		var lr := _rot(pos + Vector2(8, ly - 1.5) * s, pos, tilt)
		draw_line(ll, lr, lace_color, 1.0)
		var rl := _rot(pos + Vector2(2, ly - 1.5) * s, pos, tilt)
		var rr := _rot(pos + Vector2(8, ly) * s, pos, tilt)
		draw_line(rl, rr, lace_color, 1.0)

	# Heel counter
	var heel: PackedVector2Array = [
		pos + Vector2(-5, 8) * s,
		pos + Vector2(-2, 8) * s,
		pos + Vector2(-2, -4) * s,
		pos + Vector2(-4, -4) * s,
	]
	_rotate_points(heel, pos, tilt)
	draw_colored_polygon(heel, leather_dark)


func _rotate_points(
	points: PackedVector2Array, pivot: Vector2, angle: float,
) -> void:
	var c := cos(angle)
	var sn := sin(angle)
	for i in range(points.size()):
		var p := points[i] - pivot
		points[i] = pivot + Vector2(p.x * c - p.y * sn, p.x * sn + p.y * c)


func _rot(point: Vector2, pivot: Vector2, angle: float) -> Vector2:
	var c := cos(angle)
	var sn := sin(angle)
	var p := point - pivot
	return pivot + Vector2(p.x * c - p.y * sn, p.x * sn + p.y * c)
