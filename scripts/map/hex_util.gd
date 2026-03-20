class_name HexUtil

const SQRT3 := 1.7320508
const HEX_SIZE := 1.0

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),   # East
	Vector2i(1, -1),  # NE
	Vector2i(0, -1),  # NW
	Vector2i(-1, 0),  # West
	Vector2i(-1, 1),  # SW
	Vector2i(0, 1),   # SE
]


static func axial_to_world(q: int, r: int) -> Vector3:
	var x := HEX_SIZE * 1.5 * q
	var z := HEX_SIZE * (SQRT3 * 0.5 * q + SQRT3 * r)
	return Vector3(x, 0.0, z)


static func world_to_axial(world_pos: Vector3) -> Vector2i:
	var q := (2.0 / 3.0 * world_pos.x) / HEX_SIZE
	var r := (-1.0 / 3.0 * world_pos.x + SQRT3 / 3.0 * world_pos.z) / HEX_SIZE
	return axial_round(q, r)


static func axial_round(fq: float, fr: float) -> Vector2i:
	var fs := -fq - fr
	var q := roundi(fq)
	var r := roundi(fr)
	var s := roundi(fs)
	var q_diff := absf(q - fq)
	var r_diff := absf(r - fr)
	var s_diff := absf(s - fs)
	if q_diff > r_diff and q_diff > s_diff:
		q = -r - s
	elif r_diff > s_diff:
		r = -q - s
	return Vector2i(q, r)


static func axial_distance(a: Vector2i, b: Vector2i) -> int:
	var dq := absi(a.x - b.x)
	var dr := absi(a.y - b.y)
	var ds := absi((-a.x - a.y) - (-b.x - b.y))
	return maxi(dq, maxi(dr, ds))


static func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for dir in DIRECTIONS:
		neighbors.append(coord + dir)
	return neighbors


static func get_hexes_in_range(center: Vector2i, radius: int) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	for q in range(-radius, radius + 1):
		for r in range(maxi(-radius, -q - radius), mini(radius, -q + radius) + 1):
			results.append(center + Vector2i(q, r))
	return results


static func hex_corner_offset(i: int) -> Vector3:
	var angle_deg := 60.0 * i
	var angle_rad := deg_to_rad(angle_deg)
	return Vector3(HEX_SIZE * cos(angle_rad), 0.0, HEX_SIZE * sin(angle_rad))
