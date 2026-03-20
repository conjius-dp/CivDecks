class_name MapData
extends RefCounted

var _terrain: Dictionary = {}


func set_terrain(coord: Vector2i, terrain: TerrainType) -> void:
	_terrain[coord] = terrain


func get_terrain(coord: Vector2i) -> TerrainType:
	return _terrain.get(coord, null) as TerrainType


func has_tile(coord: Vector2i) -> bool:
	return _terrain.has(coord)


func get_walkable_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for neighbor in HexUtil.get_neighbors(coord):
		if _terrain.has(neighbor):
			var terrain: TerrainType = _terrain[neighbor] as TerrainType
			if terrain.is_passable:
				result.append(neighbor)
	return result
