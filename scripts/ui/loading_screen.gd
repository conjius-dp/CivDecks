extends Control

var _logo_tex: Texture2D = preload("res://assets/boot_logo.png")
var _progress: float = 0.0
var _loading: bool = true
var _scene_path: String = "res://scenes/main.tscn"
var _game_node: Node = null
var _instantiated: bool = false
var _frames_after_add: int = 0


func _ready() -> void:
	get_tree().root.transparent_bg = false
	ResourceLoader.load_threaded_request(_scene_path)


func _process(_delta: float) -> void:
	if _game_node and not _instantiated:
		return

	if _game_node and _instantiated:
		# Wait a few frames after adding scene so it finishes _ready
		_frames_after_add += 1
		if _frames_after_add >= 3:
			_fade_out()
			set_process(false)
		return

	if not _loading:
		return

	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status(
		_scene_path, progress
	)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		if progress.size() > 0:
			_progress = progress[0]
		queue_redraw()
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		_progress = 1.0
		_loading = false
		queue_redraw()
		# Instantiate the scene next frame to avoid blocking
		call_deferred("_instantiate_scene")
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		_loading = false
		get_tree().change_scene_to_file(_scene_path)


func _instantiate_scene() -> void:
	var scene: PackedScene = (
		ResourceLoader.load_threaded_get(_scene_path)
	)
	if scene == null:
		get_tree().change_scene_to_file(_scene_path)
		return
	_game_node = scene.instantiate()
	_game_node.visible = false
	get_tree().root.add_child(_game_node)
	# Wait a few frames for _ready to complete
	_instantiated = true
	_frames_after_add = 0


func _fade_out() -> void:
	_game_node.visible = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(
		Tween.TRANS_SINE
	)
	tween.tween_callback(func() -> void:
		queue_free()
	)


func _draw() -> void:
	var vp := get_viewport_rect().size

	# Black background
	draw_rect(Rect2(Vector2.ZERO, vp), Color.BLACK)

	# Logo centered
	if _logo_tex:
		var tex_size := _logo_tex.get_size()
		var pos := Vector2(
			(vp.x - tex_size.x) * 0.5,
			(vp.y - tex_size.y) * 0.5 - 30,
		)
		draw_texture(_logo_tex, pos)

	# Progress bar
	var bar_w := 300.0
	var bar_h := 4.0
	var bar_x := (vp.x - bar_w) * 0.5
	var bar_y := vp.y * 0.5 + 100
	draw_rect(
		Rect2(bar_x, bar_y, bar_w, bar_h),
		Color(0.15, 0.15, 0.15),
	)
	draw_rect(
		Rect2(bar_x, bar_y, bar_w * _progress, bar_h),
		Color(0.85, 0.65, 0.2),
	)
