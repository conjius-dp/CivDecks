extends SceneTree

var _pass_count: int = 0
var _fail_count: int = 0
var _current_error: String = ""
var _errors: Array[String] = []


func _init() -> void:
	var suites: Array[Script] = _discover_tests()
	for script in suites:
		_run_suite(script)
	_print_summary()
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)


func _discover_tests() -> Array[Script]:
	var result: Array[Script] = []
	var dir := DirAccess.open("res://tests")
	if dir == null:
		printerr("Cannot open res://tests")
		quit(1)
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("test_") and file_name.ends_with(".gd") and file_name != "test_runner.gd" and file_name != "test_assert.gd":
			var script: Script = load("res://tests/" + file_name) as Script
			if script:
				result.append(script)
		file_name = dir.get_next()
	return result


func _run_suite(script: Script) -> void:
	var suite_name: String = script.resource_path.get_file().get_basename()
	print("\n--- %s ---" % suite_name)
	var instance: RefCounted = script.new()

	if instance.has_method("before"):
		instance.call("before")

	var methods: Array[Dictionary] = script.get_script_method_list()
	for method in methods:
		var method_name: String = method["name"]
		if not method_name.begins_with("test_"):
			continue

		if instance.has_method("before_each"):
			instance.call("before_each")

		TestAssert._last_error = ""
		instance.call(method_name)
		var err: String = TestAssert._last_error

		if err == "":
			_pass_count += 1
			print("  PASS: %s" % method_name)
		else:
			_fail_count += 1
			var full_err := "%s.%s: %s" % [suite_name, method_name, err]
			_errors.append(full_err)
			print("  FAIL: %s — %s" % [method_name, err])

		if instance.has_method("after_each"):
			instance.call("after_each")

	if instance.has_method("after"):
		instance.call("after")


func _print_summary() -> void:
	print("\n========================================")
	print("Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _errors.size() > 0:
		print("\nFailures:")
		for err in _errors:
			print("  • %s" % err)
	print("========================================")
