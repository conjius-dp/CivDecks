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
var _move_tween: Tween = null
var _model: Node3D
var _anim_player: AnimationPlayer

var _model_scene_path: String = (
	"res://assets/models/characters/scout.glb"
)


func _ready() -> void:
	# Remove placeholder mesh if present
	var old_mesh: Node = get_node_or_null("MeshInstance3D")
	if old_mesh:
		old_mesh.queue_free()
	var scene: PackedScene = load(_model_scene_path) as PackedScene
	if scene == null:
		return
	_model = scene.instantiate()
	_model.scale = Vector3(0.5, 0.5, 0.5)
	add_child(_model)
	_anim_player = _model.get_node_or_null(
		"AnimationPlayer"
	) as AnimationPlayer
	_apply_color_wash()
	if _anim_player and _anim_player.has_animation("Idle"):
		_anim_player.play("Idle")


func is_moving() -> bool:
	return _is_moving


func place_at(coord: Vector2i, terrain_height: float = 0.0) -> void:
	state.place_at(coord)
	position = HexUtil.axial_to_world(coord.x, coord.y)
	position.y = terrain_height + 0.5


func move_to(coord: Vector2i, terrain_height: float = 0.0) -> void:
	state.move_to(coord)
	var target := HexUtil.axial_to_world(coord.x, coord.y)
	target.y = terrain_height + 0.5
	_is_moving = true
	_play_anim("Walking_A")
	_face_toward(target)
	if _move_tween and _move_tween.is_running():
		_move_tween.kill()
	_move_tween = create_tween()
	var distance := position.distance_to(target)
	var duration := distance / move_speed
	_move_tween.tween_property(self, "position", target, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_move_tween.finished.connect(_on_move_finished)


func move_along_path(path_coords: Array[Vector2i], terrain_heights: Array[float]) -> void:
	if path_coords.size() <= 1:
		movement_finished.emit()
		return
	state.move_to(path_coords[path_coords.size() - 1])
	_is_moving = true
	_play_anim("Walking_A")
	var first_target := HexUtil.axial_to_world(
		path_coords[1].x, path_coords[1].y
	)
	_face_toward(first_target)
	if _move_tween and _move_tween.is_running():
		_move_tween.kill()
	_move_tween = create_tween()
	for i in range(1, path_coords.size()):
		var target := HexUtil.axial_to_world(path_coords[i].x, path_coords[i].y)
		target.y = terrain_heights[i] + 0.5
		var prev := path_coords[i - 1]
		var prev_world := HexUtil.axial_to_world(prev.x, prev.y)
		var step_distance := prev_world.distance_to(
			HexUtil.axial_to_world(path_coords[i].x, path_coords[i].y)
		)
		var duration := step_distance / move_speed
		_move_tween.tween_property(self, "position", target, duration) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_move_tween.finished.connect(_on_move_finished)


func _on_move_finished() -> void:
	_is_moving = false
	_play_anim("Idle")
	movement_finished.emit()


func _play_anim(anim_name: String) -> void:
	if _anim_player and _anim_player.has_animation(anim_name):
		_anim_player.play(anim_name)


func _face_toward(target: Vector3) -> void:
	var dir := target - position
	dir.y = 0.0
	if dir.length_squared() > 0.001:
		_model.look_at(position + dir, Vector3.UP)


func _apply_color_wash() -> void:
	if not _model:
		return
	for child in _model.get_children():
		if child is MeshInstance3D:
			var mi: MeshInstance3D = child as MeshInstance3D
			var mat := mi.get_active_material(0)
			if mat is StandardMaterial3D:
				var m: StandardMaterial3D = mat.duplicate()
				m.albedo_color = m.albedo_color.lerp(
					avatar_color, 0.3
				)
				mi.material_override = m
