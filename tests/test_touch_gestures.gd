extends RefCounted

var _Mgr: GDScript = preload(
	"res://scripts/input/touch_input_manager.gd"
)
var _Helpers: GDScript = preload(
	"res://scripts/input/touch_test_helpers.gd"
)

var _mgr: RefCounted
var _tapped: Array = []
var _drags_started: Array = []
var _drags_moved: Array = []
var _drags_ended: Array = []
var _swipes_up: Array = []
var _swipes_down: Array = []
var _swipes_h: Array = []
var _pinches: Array = []
var _two_drags: Array = []


func _make_touch(
	idx: int, pos: Vector2, pressed: bool,
) -> InputEventScreenTouch:
	return _Helpers.make_touch(idx, pos, pressed) as InputEventScreenTouch


func _make_drag(
	idx: int, pos: Vector2, rel: Vector2,
) -> InputEventScreenDrag:
	return _Helpers.make_drag(idx, pos, rel) as InputEventScreenDrag


func before_each() -> void:
	_mgr = _Mgr.new()
	_mgr.viewport_size = Vector2(1920, 1080)
	_tapped.clear()
	_drags_started.clear()
	_drags_moved.clear()
	_drags_ended.clear()
	_swipes_up.clear()
	_swipes_down.clear()
	_swipes_h.clear()
	_pinches.clear()
	_two_drags.clear()
	_mgr.tapped.connect(func(p: Vector2) -> void: _tapped.append(p))
	_mgr.drag_started.connect(
		func(p: Vector2) -> void: _drags_started.append(p)
	)
	_mgr.drag_moved.connect(
		func(p: Vector2, d: Vector2) -> void:
			_drags_moved.append({"pos": p, "delta": d})
	)
	_mgr.drag_ended.connect(
		func(p: Vector2) -> void: _drags_ended.append(p)
	)
	_mgr.swiped_up.connect(
		func(p: Vector2) -> void: _swipes_up.append(p)
	)
	_mgr.swiped_down.connect(
		func(p: Vector2) -> void: _swipes_down.append(p)
	)
	_mgr.swiped_horizontal.connect(
		func(dir: int) -> void: _swipes_h.append(dir)
	)
	_mgr.pinched.connect(
		func(c: Vector2, f: float) -> void:
			_pinches.append({"center": c, "factor": f})
	)
	_mgr.two_finger_dragged.connect(
		func(d: Vector2) -> void: _two_drags.append(d)
	)


func test_tap_detected_on_quick_release() -> void:
	var pos := Vector2(500, 400)
	_mgr.handle_touch(_make_touch(0, pos, true))
	_mgr.handle_touch(_make_touch(0, pos, false))
	TestAssert.assert_eq(_tapped.size(), 1, "should emit one tap")
	TestAssert.assert_eq(_tapped[0], pos, "tap position")


func test_tap_not_emitted_after_drag() -> void:
	var start := Vector2(500, 400)
	_mgr.handle_touch(_make_touch(0, start, true))
	var far := start + Vector2(100, 0)
	_mgr.handle_drag(_make_drag(0, far, Vector2(100, 0)))
	_mgr.handle_touch(_make_touch(0, far, false))
	TestAssert.assert_eq(_tapped.size(), 0, "drag should suppress tap")


func test_single_drag_emitted_past_threshold() -> void:
	var start := Vector2(500, 400)
	_mgr.handle_touch(_make_touch(0, start, true))
	var step := Vector2(20, 0)
	var pos := start + step
	_mgr.handle_drag(_make_drag(0, pos, step))
	TestAssert.assert_eq(
		_drags_started.size(), 1, "drag should start"
	)
	var step2 := Vector2(10, 0)
	pos += step2
	_mgr.handle_drag(_make_drag(0, pos, step2))
	TestAssert.assert_eq(
		_drags_moved.size(), 1, "drag should move"
	)
	_mgr.handle_touch(_make_touch(0, pos, false))
	TestAssert.assert_eq(
		_drags_ended.size(), 1, "drag should end"
	)


func test_swipe_up_from_bottom_edge() -> void:
	var bottom_y: float = 1080.0 * 0.9
	var start := Vector2(500, bottom_y)
	_mgr.handle_touch(_make_touch(0, start, true))
	var delta := Vector2(0, -60)
	_mgr.handle_drag(_make_drag(0, start + delta, delta))
	_mgr.handle_touch(_make_touch(0, start + delta, false))
	TestAssert.assert_eq(
		_swipes_up.size(), 1, "should detect swipe up"
	)
	TestAssert.assert_eq(
		_tapped.size(), 0, "swipe should not tap"
	)


func test_swipe_up_from_middle_is_drag_not_swipe() -> void:
	var start := Vector2(500, 400)
	_mgr.handle_touch(_make_touch(0, start, true))
	var delta := Vector2(0, -60)
	_mgr.handle_drag(_make_drag(0, start + delta, delta))
	_mgr.handle_touch(_make_touch(0, start + delta, false))
	TestAssert.assert_eq(
		_swipes_up.size(), 0,
		"swipe up only from bottom edge",
	)
	TestAssert.assert_eq(
		_drags_started.size(), 1, "should be a drag instead"
	)


func test_swipe_down_when_gallery_open() -> void:
	_mgr.gallery_open = true
	var start := Vector2(500, 300)
	_mgr.handle_touch(_make_touch(0, start, true))
	var delta := Vector2(0, 60)
	_mgr.handle_drag(_make_drag(0, start + delta, delta))
	_mgr.handle_touch(_make_touch(0, start + delta, false))
	TestAssert.assert_eq(
		_swipes_down.size(), 1, "should detect swipe down"
	)


func test_swipe_down_ignored_when_gallery_closed() -> void:
	_mgr.gallery_open = false
	var start := Vector2(500, 300)
	_mgr.handle_touch(_make_touch(0, start, true))
	var delta := Vector2(0, 60)
	_mgr.handle_drag(_make_drag(0, start + delta, delta))
	_mgr.handle_touch(_make_touch(0, start + delta, false))
	TestAssert.assert_eq(
		_swipes_down.size(), 0,
		"swipe down only when gallery open",
	)


func test_horizontal_swipe_left_in_gallery() -> void:
	_mgr.gallery_open = true
	var start := Vector2(800, 400)
	_mgr.handle_touch(_make_touch(0, start, true))
	var delta := Vector2(-80, 5)
	_mgr.handle_drag(_make_drag(0, start + delta, delta))
	_mgr.handle_touch(_make_touch(0, start + delta, false))
	TestAssert.assert_eq(
		_swipes_h.size(), 1, "should detect horizontal swipe"
	)
	TestAssert.assert_eq(
		_swipes_h[0], -1, "swipe left should be -1"
	)


func test_horizontal_swipe_right_in_gallery() -> void:
	_mgr.gallery_open = true
	var start := Vector2(800, 400)
	_mgr.handle_touch(_make_touch(0, start, true))
	var delta := Vector2(80, -5)
	_mgr.handle_drag(_make_drag(0, start + delta, delta))
	_mgr.handle_touch(_make_touch(0, start + delta, false))
	TestAssert.assert_eq(
		_swipes_h.size(), 1, "should detect horizontal swipe"
	)
	TestAssert.assert_eq(
		_swipes_h[0], 1, "swipe right should be +1"
	)


func test_horizontal_swipe_ignored_when_gallery_closed() -> void:
	_mgr.gallery_open = false
	var start := Vector2(800, 400)
	_mgr.handle_touch(_make_touch(0, start, true))
	var delta := Vector2(-80, 5)
	_mgr.handle_drag(_make_drag(0, start + delta, delta))
	_mgr.handle_touch(_make_touch(0, start + delta, false))
	TestAssert.assert_eq(
		_swipes_h.size(), 0,
		"horizontal swipe only in gallery",
	)


func test_pinch_zoom_out() -> void:
	var a := Vector2(400, 500)
	var b := Vector2(600, 500)
	_mgr.handle_touch(_make_touch(0, a, true))
	_mgr.handle_touch(_make_touch(1, b, true))
	var spread := Vector2(20, 0)
	_mgr.handle_drag(_make_drag(0, a - spread, -spread))
	_mgr.handle_drag(_make_drag(1, b + spread, spread))
	TestAssert.assert_true(
		_pinches.size() > 0, "should emit pinch"
	)
	var factor: float = _pinches[0]["factor"] as float
	TestAssert.assert_true(
		factor > 1.0, "fingers apart = factor > 1 (zoom in)"
	)


func test_pinch_zoom_in() -> void:
	var a := Vector2(300, 500)
	var b := Vector2(700, 500)
	_mgr.handle_touch(_make_touch(0, a, true))
	_mgr.handle_touch(_make_touch(1, b, true))
	var squeeze := Vector2(30, 0)
	_mgr.handle_drag(_make_drag(0, a + squeeze, squeeze))
	_mgr.handle_drag(_make_drag(1, b - squeeze, -squeeze))
	TestAssert.assert_true(
		_pinches.size() > 0, "should emit pinch"
	)
	var factor: float = _pinches[0]["factor"] as float
	TestAssert.assert_true(
		factor < 1.0, "fingers together = factor < 1 (zoom out)"
	)


func test_two_finger_drag() -> void:
	var a := Vector2(400, 500)
	var b := Vector2(600, 500)
	_mgr.handle_touch(_make_touch(0, a, true))
	_mgr.handle_touch(_make_touch(1, b, true))
	var delta := Vector2(0, -30)
	_mgr.handle_drag(_make_drag(0, a + delta, delta))
	_mgr.handle_drag(_make_drag(1, b + delta, delta))
	TestAssert.assert_true(
		_two_drags.size() > 0, "should emit two-finger drag"
	)
	var d: Vector2 = _two_drags[0] as Vector2
	TestAssert.assert_true(
		d.y < 0, "should have negative y delta"
	)


func test_two_finger_does_not_emit_single_drag() -> void:
	var a := Vector2(400, 500)
	var b := Vector2(600, 500)
	_mgr.handle_touch(_make_touch(0, a, true))
	_mgr.handle_touch(_make_touch(1, b, true))
	var delta := Vector2(0, -30)
	_mgr.handle_drag(_make_drag(0, a + delta, delta))
	_mgr.handle_drag(_make_drag(1, b + delta, delta))
	TestAssert.assert_eq(
		_drags_started.size(), 0,
		"two-finger should not emit single drag",
	)


func test_gallery_swipe_does_not_emit_tap() -> void:
	_mgr.gallery_open = true
	var start := Vector2(800, 400)
	_mgr.handle_touch(_make_touch(0, start, true))
	var delta := Vector2(-60, 5)
	_mgr.handle_drag(_make_drag(0, start + delta, delta))
	_mgr.handle_touch(_make_touch(0, start + delta, false))
	TestAssert.assert_eq(
		_tapped.size(), 0,
		"gallery swipe should not emit tap",
	)


func test_gallery_tap_still_works() -> void:
	_mgr.gallery_open = true
	var pos := Vector2(800, 400)
	_mgr.handle_touch(_make_touch(0, pos, true))
	_mgr.handle_touch(_make_touch(0, pos, false))
	TestAssert.assert_eq(
		_tapped.size(), 1, "gallery tap should still work"
	)


func test_releasing_second_finger_resets_to_idle() -> void:
	var a := Vector2(400, 500)
	var b := Vector2(600, 500)
	_mgr.handle_touch(_make_touch(0, a, true))
	_mgr.handle_touch(_make_touch(1, b, true))
	_mgr.handle_touch(_make_touch(1, b, false))
	_mgr.handle_touch(_make_touch(0, a, false))
	TestAssert.assert_eq(
		_tapped.size(), 0,
		"two-finger release should not tap",
	)
