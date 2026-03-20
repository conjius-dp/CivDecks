class_name TestAssert
extends RefCounted

static var _last_error: String = ""


static func fail(msg: String) -> void:
	if _last_error == "":
		_last_error = msg
	push_error("ASSERTION FAILED: " + msg)


static func assert_eq(actual: Variant, expected: Variant, context: String = "") -> void:
	if not is_same(actual, expected) and actual != expected:
		var msg := "Expected '%s' but got '%s'" % [str(expected), str(actual)]
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_ne(actual: Variant, expected: Variant, context: String = "") -> void:
	if actual == expected:
		var msg := "Expected value to differ from '%s'" % str(expected)
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_true(value: bool, context: String = "") -> void:
	if not value:
		var msg := "Expected true but got false"
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_false(value: bool, context: String = "") -> void:
	if value:
		var msg := "Expected false but got true"
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_null(value: Variant, context: String = "") -> void:
	if value != null:
		var msg := "Expected null but got '%s'" % str(value)
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_not_null(value: Variant, context: String = "") -> void:
	if value == null:
		var msg := "Expected non-null value"
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_contains(array: Array, item: Variant, context: String = "") -> void:
	if item not in array:
		var msg := "Expected array to contain '%s', got %s" % [str(item), str(array)]
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_not_contains(array: Array, item: Variant, context: String = "") -> void:
	if item in array:
		var msg := "Expected array NOT to contain '%s'" % str(item)
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_size(array: Array, expected_size: int, context: String = "") -> void:
	if array.size() != expected_size:
		var msg := "Expected array size %d but got %d" % [expected_size, array.size()]
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)


static func assert_gt(actual: Variant, expected: Variant, context: String = "") -> void:
	if actual <= expected:
		var msg := "Expected '%s' > '%s'" % [str(actual), str(expected)]
		if context != "":
			msg = "%s: %s" % [context, msg]
		fail(msg)
