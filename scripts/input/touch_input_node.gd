extends Node

var manager: RefCounted
var _manager_script: GDScript = preload(
	"res://scripts/input/touch_input_manager.gd"
)


func _ready() -> void:
	manager = _manager_script.new()
	var vp := get_viewport()
	if vp:
		manager.viewport_size = vp.get_visible_rect().size
		vp.size_changed.connect(_on_viewport_resize)


func _on_viewport_resize() -> void:
	var vp := get_viewport()
	if vp:
		manager.viewport_size = vp.get_visible_rect().size


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		manager.handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		manager.handle_drag(event as InputEventScreenDrag)
