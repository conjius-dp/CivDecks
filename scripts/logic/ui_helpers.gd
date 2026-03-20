class_name UIHelpers
extends RefCounted


static func calc_desc_font_size(text: String) -> int:
	var length := text.length()
	if length < 20:
		return 13
	if length < 30:
		return 12
	if length < 45:
		return 11
	return 10
