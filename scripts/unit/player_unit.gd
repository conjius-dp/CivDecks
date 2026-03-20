extends Node3D

signal movement_finished

@export var move_speed: float = 8.0

var state: PlayerState = PlayerState.new()
var avatar_color: Color = Color(0.9, 0.2, 0.2, 1)

var current_coord: Vector2i:
	get: return state.current_coord
	set(value): state.current_coord = value

var unit_name: String:
	get: return state.unit_name

var health: int:
	get: return state.health

var max_health: int:
	get: return state.max_health

var attack: int:
	get: return state.attack

var defense: int:
	get: return state.defense

var _is_moving: bool = false
var _move_target: Vector3 = Vector3.ZERO


func place_at(coord: Vector2i, terrain_height: float = 0.0) -> void:
	state.place_at(coord)
	position = HexUtil.axial_to_world(coord.x, coord.y)
	position.y = terrain_height + 0.5


func move_to(coord: Vector2i, terrain_height: float = 0.0) -> void:
	state.move_to(coord)
	_move_target = HexUtil.axial_to_world(coord.x, coord.y)
	_move_target.y = terrain_height + 0.5
	_is_moving = true


func _process(delta: float) -> void:
	if _is_moving:
		position = position.move_toward(_move_target, move_speed * delta)
		if position.distance_to(_move_target) < 0.01:
			position = _move_target
			_is_moving = false
			movement_finished.emit()
