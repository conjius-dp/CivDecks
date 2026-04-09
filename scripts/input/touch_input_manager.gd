class_name TouchInputManager
extends RefCounted

signal tapped(pos: Vector2)
signal drag_started(pos: Vector2)
signal drag_moved(pos: Vector2, delta: Vector2)
signal drag_ended(pos: Vector2)
signal swiped_up(pos: Vector2)
signal swiped_down(pos: Vector2)
signal swiped_horizontal(direction: int)
signal pinched(center: Vector2, factor: float)
signal two_finger_dragged(delta: Vector2)

enum State {
	IDLE,
	PENDING,
	SINGLE_DRAG,
	TWO_FINGER,
}

const TAP_MAX_DIST := 15.0
const SWIPE_THRESHOLD := 40.0
const GALLERY_SWIPE_ZONE := 0.15

var gallery_open: bool = false
var viewport_size: Vector2 = Vector2(1920, 1080)

var _state: int = State.IDLE
var _touches: Dictionary = {}
var _start_positions: Dictionary = {}
var _prev_two_dist: float = 0.0


func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touches[event.index] = event.position
		_start_positions[event.index] = event.position
		if _state == State.IDLE and event.index == 0:
			_state = State.PENDING
		elif _state == State.PENDING and event.index == 1:
			_state = State.TWO_FINGER
			var a: Vector2 = _touches[0] as Vector2
			var b: Vector2 = _touches[1] as Vector2
			_prev_two_dist = a.distance_to(b)
	else:
		_on_finger_released(event)
		_touches.erase(event.index)
		_start_positions.erase(event.index)


func handle_drag(event: InputEventScreenDrag) -> void:
	var prev_pos: Vector2 = _touches.get(
		event.index, event.position
	) as Vector2
	_touches[event.index] = event.position

	if _state == State.TWO_FINGER:
		_handle_two_finger_drag(event)
		return

	if _state == State.PENDING and event.index == 0:
		var start: Vector2 = _start_positions.get(
			0, event.position
		) as Vector2
		var dist := event.position.distance_to(start)
		if dist >= TAP_MAX_DIST:
			var start_in_bottom := (
				start.y >= viewport_size.y * (1.0 - GALLERY_SWIPE_ZONE)
			)
			if start_in_bottom and not gallery_open:
				_state = State.SINGLE_DRAG
			else:
				_state = State.SINGLE_DRAG
				drag_started.emit(start)
			return

	if _state == State.SINGLE_DRAG and event.index == 0:
		drag_moved.emit(event.position, event.relative)


func _on_finger_released(event: InputEventScreenTouch) -> void:
	if _state == State.TWO_FINGER:
		_state = State.IDLE
		return

	if _state == State.PENDING and event.index == 0:
		tapped.emit(event.position)
		_state = State.IDLE
		return

	if _state == State.SINGLE_DRAG and event.index == 0:
		var start: Vector2 = _start_positions.get(
			0, event.position
		) as Vector2
		var total_delta := event.position - start
		var abs_x := absf(total_delta.x)
		var abs_y := absf(total_delta.y)

		var start_in_bottom := (
			start.y >= viewport_size.y * (1.0 - GALLERY_SWIPE_ZONE)
		)

		if (start_in_bottom and not gallery_open
			and abs_y >= SWIPE_THRESHOLD
			and abs_y > abs_x
			and total_delta.y < 0
		):
			swiped_up.emit(start)
			_state = State.IDLE
			return

		if (gallery_open and abs_y >= SWIPE_THRESHOLD
			and abs_y > abs_x and total_delta.y > 0
		):
			drag_ended.emit(event.position)
			swiped_down.emit(start)
			_state = State.IDLE
			return

		if (gallery_open and abs_x >= SWIPE_THRESHOLD
			and abs_x > abs_y
		):
			var dir := 1 if total_delta.x > 0 else -1
			swiped_horizontal.emit(dir)
			_state = State.IDLE
			return

		drag_ended.emit(event.position)
		_state = State.IDLE
		return

	_state = State.IDLE


func _handle_two_finger_drag(
	event: InputEventScreenDrag,
) -> void:
	if not _touches.has(0) or not _touches.has(1):
		return

	var a: Vector2 = _touches[0] as Vector2
	var b: Vector2 = _touches[1] as Vector2
	var new_dist := a.distance_to(b)

	if _prev_two_dist > 0.01:
		var factor := new_dist / _prev_two_dist
		var center := (a + b) * 0.5
		var dist_change := absf(new_dist - _prev_two_dist)
		var avg_relative := event.relative
		var rel_mag := avg_relative.length()

		if dist_change > rel_mag * 0.3:
			pinched.emit(center, factor)
		else:
			two_finger_dragged.emit(event.relative)

	_prev_two_dist = new_dist
