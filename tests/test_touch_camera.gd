extends RefCounted

var _CameraScript: GDScript = preload(
	"res://scripts/camera/strategy_camera.gd"
)


func _make_cam() -> Node3D:
	var cam := Node3D.new()
	cam.set_script(_CameraScript)
	return cam


func test_pinch_in_zooms_out() -> void:
	var cam := _make_cam()
	cam.set("_target_zoom", 15.0)
	cam.call("touch_zoom", 0.9)
	var zoom: float = cam.get("_target_zoom") as float
	TestAssert.assert_true(
		zoom > 15.0,
		"fingers together increases camera distance"
	)


func test_pinch_out_zooms_in() -> void:
	var cam := _make_cam()
	cam.set("_target_zoom", 15.0)
	cam.call("touch_zoom", 1.1)
	var zoom: float = cam.get("_target_zoom") as float
	TestAssert.assert_true(
		zoom < 15.0,
		"fingers apart decreases camera distance"
	)


func test_touch_zoom_clamps_to_min() -> void:
	var cam := _make_cam()
	cam.set("_target_zoom", 4.0)
	cam.call("touch_zoom", 0.1)
	var zoom: float = cam.get("_target_zoom") as float
	var zoom_min: float = cam.get("zoom_min") as float
	TestAssert.assert_true(
		zoom >= zoom_min, "zoom should not go below min"
	)


func test_touch_zoom_clamps_to_max() -> void:
	var cam := _make_cam()
	cam.set("_target_zoom", 28.0)
	cam.call("touch_zoom", 10.0)
	var zoom: float = cam.get("_target_zoom") as float
	var zoom_max: float = cam.get("zoom_max") as float
	TestAssert.assert_true(
		zoom <= zoom_max, "zoom should not go above max"
	)


func test_touch_tilt_adjusts_target() -> void:
	var cam := _make_cam()
	cam.set("_target_tilt", 60.0)
	cam.call("touch_tilt", -10.0)
	var tilt: float = cam.get("_target_tilt") as float
	TestAssert.assert_true(
		tilt < 60.0, "negative delta should tilt down"
	)


func test_touch_tilt_clamps_to_min() -> void:
	var cam := _make_cam()
	cam.set("_target_tilt", 20.0)
	cam.call("touch_tilt", -100.0)
	var tilt: float = cam.get("_target_tilt") as float
	var tilt_min: float = cam.get("tilt_min") as float
	TestAssert.assert_true(
		tilt >= tilt_min, "tilt should not go below min"
	)


func test_touch_tilt_clamps_to_max() -> void:
	var cam := _make_cam()
	cam.set("_target_tilt", 80.0)
	cam.call("touch_tilt", 100.0)
	var tilt: float = cam.get("_target_tilt") as float
	var tilt_max: float = cam.get("tilt_max") as float
	TestAssert.assert_true(
		tilt <= tilt_max, "tilt should not go above max"
	)


func test_touch_orbit_changes_rotation() -> void:
	var cam := _make_cam()
	cam.set("_target_rot_y", 0.0)
	cam.call("touch_orbit", 0.5)
	var rot: float = cam.get("_target_rot_y") as float
	TestAssert.assert_true(
		absf(rot) > 0.0, "orbit should change rotation"
	)


func test_touch_orbit_opposite_directions() -> void:
	var cam := _make_cam()
	cam.set("_target_rot_y", 0.0)
	cam.call("touch_orbit", 1.0)
	var first: float = cam.get("_target_rot_y") as float
	cam.set("_target_rot_y", 0.0)
	cam.call("touch_orbit", -1.0)
	var second: float = cam.get("_target_rot_y") as float
	TestAssert.assert_true(
		first * second < 0.0,
		"opposite deltas should give opposite signs"
	)
