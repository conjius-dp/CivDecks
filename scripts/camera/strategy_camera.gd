extends Node3D

@export var pan_speed: float = 15.0
@export var zoom_speed: float = 2.0
@export var zoom_min: float = 3.0
@export var zoom_max: float = 30.0
@export var rotate_speed: float = 0.005
@export var drag_speed: float = 0.02

var _current_zoom: float = 15.0
var _dragging: bool = false


func _ready() -> void:
	_apply_zoom()


func _process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("pan_up"):
		input_dir.y -= 1.0
	if Input.is_action_pressed("pan_down"):
		input_dir.y += 1.0
	if Input.is_action_pressed("pan_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("pan_right"):
		input_dir.x += 1.0

	if input_dir != Vector2.ZERO:
		var forward := -global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		var right := global_transform.basis.x
		right.y = 0.0
		right = right.normalized()
		global_position += (forward * -input_dir.y + right * input_dir.x) * pan_speed * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_current_zoom = maxf(zoom_min, _current_zoom - zoom_speed)
			_apply_zoom()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_current_zoom = minf(zoom_max, _current_zoom + zoom_speed)
			_apply_zoom()

	if event is InputEventPanGesture:
		# Vertical: zoom
		_current_zoom = clampf(
			_current_zoom + event.delta.y * zoom_speed * 0.3, zoom_min, zoom_max
		)
		_apply_zoom()
		# Horizontal: rotate
		rotate_y(event.delta.x * rotate_speed * 10.0)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed

	if event is InputEventMouseMotion:
		if _dragging:
			var forward := -global_transform.basis.z
			forward.y = 0.0
			forward = forward.normalized()
			var right := global_transform.basis.x
			right.y = 0.0
			right = right.normalized()
			var move: Vector3 = right * -event.relative.x + forward * event.relative.y
			global_position += move * drag_speed * _current_zoom * 0.05
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			rotate_y(-event.relative.x * rotate_speed)


func _apply_zoom() -> void:
	$CameraPivot/Camera3D.position.z = _current_zoom
