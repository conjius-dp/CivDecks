extends RefCounted


func test_desc_font_size_short() -> void:
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size("Move 1 hex"), 13)


func test_desc_font_size_medium() -> void:
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size("Move to an adjacent hex tile"), 12)


func test_desc_font_size_long() -> void:
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size("Reveal all tiles within 2 hexes of target"), 11)


func test_desc_font_size_very_long() -> void:
	var long_text := "Gather resources from an adjacent tile and add them to your stockpile immediately"
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size(long_text), 10)


func test_desc_font_size_boundary_19() -> void:
	var text := "a".repeat(19)
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size(text), 13)


func test_desc_font_size_boundary_20() -> void:
	var text := "a".repeat(20)
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size(text), 12)


func test_desc_font_size_boundary_29() -> void:
	var text := "a".repeat(29)
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size(text), 12)


func test_desc_font_size_boundary_30() -> void:
	var text := "a".repeat(30)
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size(text), 11)


func test_desc_font_size_boundary_44() -> void:
	var text := "a".repeat(44)
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size(text), 11)


func test_desc_font_size_boundary_45() -> void:
	var text := "a".repeat(45)
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size(text), 10)


func test_desc_font_size_empty() -> void:
	TestAssert.assert_eq(UIHelpers.calc_desc_font_size(""), 13)
