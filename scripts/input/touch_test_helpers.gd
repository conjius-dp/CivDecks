class_name TouchTestHelpers
extends RefCounted


static func make_touch(
	index: int, pos: Vector2, pressed: bool,
) -> InputEventScreenTouch:
	var ev := InputEventScreenTouch.new()
	ev.index = index
	ev.position = pos
	ev.pressed = pressed
	return ev


static func make_drag(
	index: int, pos: Vector2, relative: Vector2,
) -> InputEventScreenDrag:
	var ev := InputEventScreenDrag.new()
	ev.index = index
	ev.position = pos
	ev.relative = relative
	return ev
