extends Node

var _frame_count: int = 0
var _state: int = 0
var _output_dir: String = ""


func _ready() -> void:
	_output_dir = OS.get_user_data_dir()
	DirAccess.make_dir_recursive_absolute(_output_dir + "/screenshots")
	print("Screenshot output dir: " + _output_dir)


func _process(_delta: float) -> void:
	_frame_count += 1
	if _state == 0 and _frame_count >= 120:
		_capture("screenshot-main.png")
		_open_gallery()
		_state = 1
		_frame_count = 0
	elif _state == 1 and _frame_count >= 90:
		_capture("screenshot-gallery.png")
		get_tree().quit()


func _capture(filename: String) -> void:
	var path: String = _output_dir + "/screenshots/" + filename
	var img := get_viewport().get_texture().get_image()
	if img:
		img.save_png(path)
		print("Captured: " + path)
	else:
		print("Failed to capture: " + filename)


func _open_gallery() -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_RIGHT
	press.pressed = true
	press.position = Vector2(960, 900)
	press.global_position = press.position
	Input.parse_input_event(press)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_RIGHT
	release.pressed = false
	release.position = Vector2(960, 900)
	release.global_position = release.position
	Input.parse_input_event(release)
