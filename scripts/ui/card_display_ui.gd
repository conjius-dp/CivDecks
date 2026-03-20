extends PanelContainer

signal drag_started(card: CardData)
signal drag_ended(card: CardData, target: Vector2i, success: bool)

const _CARD_ICONS: Dictionary = {
	CardData.CardType.MOVE: "▲",
	CardData.CardType.SCOUT: "◉",
	CardData.CardType.GATHER: "◆",
}

var card_data: CardData
var hex_map: Node3D
var camera: Camera3D
var card_effects: Node
var active_unit: Node3D
var arrow_indicator: MeshInstance3D

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _original_position: Vector2 = Vector2.ZERO
var _valid_targets: Array[Vector2i] = []


func setup(card: CardData) -> void:
	card_data = card
	var base: Color = card.card_color
	var dark: Color = base.darkened(0.35)
	var light: Color = base.lightened(0.2)

	# Outer container — transparent, rounded corners
	var outer := StyleBoxFlat.new()
	outer.bg_color = Color(0, 0, 0, 0)
	outer.corner_radius_top_left = 8
	outer.corner_radius_top_right = 8
	outer.corner_radius_bottom_left = 8
	outer.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", outer)

	# Header — dark, rounded top corners
	_apply_section_style($VBox/Header, dark, 8, 8, 0, 0)
	$VBox/Header/CardName.text = card.card_name
	$VBox/Header/CardName.add_theme_font_size_override("font_size", 12)
	$VBox/Header/CardName.add_theme_color_override("font_color", Color.WHITE)

	# Avatar — lighter shade
	_apply_section_style($VBox/Avatar, light, 0, 0, 0, 0)
	var icon: String = _CARD_ICONS.get(card.card_type, "?") as String
	$VBox/Avatar/AvatarLabel.text = icon
	$VBox/Avatar/AvatarLabel.add_theme_font_size_override("font_size", 28)
	$VBox/Avatar/AvatarLabel.add_theme_color_override("font_color", dark)

	# Description — base color
	_apply_section_style($VBox/DescSection, base, 0, 0, 0, 0)
	$VBox/DescSection/Description.text = card.description
	var desc_size := _calc_desc_font_size(card.description)
	$VBox/DescSection/Description.add_theme_font_size_override("font_size", desc_size)
	$VBox/DescSection/Description.add_theme_color_override("font_color", Color.WHITE)

	# Footer — dark, rounded bottom corners
	_apply_section_style($VBox/Footer, dark, 0, 0, 8, 8)
	$VBox/Footer/FooterLabel.text = "Range %d" % card.range_value
	$VBox/Footer/FooterLabel.add_theme_font_size_override("font_size", 10)
	$VBox/Footer/FooterLabel.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))


func _apply_section_style(
	node: PanelContainer, color: Color,
	tl: int, tr: int, bl: int, br: int,
) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = tl
	style.corner_radius_top_right = tr
	style.corner_radius_bottom_left = bl
	style.corner_radius_bottom_right = br
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	node.add_theme_stylebox_override("panel", style)


func _calc_desc_font_size(text: String) -> int:
	var length := text.length()
	if length < 20:
		return 13
	if length < 30:
		return 12
	if length < 45:
		return 11
	return 10


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not _dragging:
			_start_drag(event.global_position)
			accept_event()
		elif not event.pressed and _dragging:
			_end_drag(event.global_position)
			accept_event()


func _input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventMouseMotion:
		global_position = event.global_position - _drag_offset
		_update_hover(event.global_position)
	elif event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_end_drag(event.global_position)


func _start_drag(mouse_pos: Vector2) -> void:
	_dragging = true
	_original_position = global_position
	_drag_offset = mouse_pos - global_position

	z_index = 100
	modulate = Color(1.0, 1.0, 1.0, 0.5)
	scale = Vector2(1.05, 1.05)

	# Cache valid targets once at drag start
	_valid_targets.clear()
	if hex_map and card_effects and active_unit:
		_valid_targets = card_effects.get_valid_targets(
			card_data, active_unit.current_coord
		)
		hex_map.highlight_tiles(_valid_targets, Color(0.3, 0.8, 1.0, 0.8))

	drag_started.emit(card_data)


func _end_drag(mouse_pos: Vector2) -> void:
	_dragging = false
	z_index = 0
	modulate = Color.WHITE
	scale = Vector2.ONE

	hex_map.clear_highlights()
	if arrow_indicator:
		arrow_indicator.hide_arrow()

	var target := _raycast_hex(mouse_pos)
	var is_valid := target != Vector2i(-999, -999) and _is_valid_target(target)
	_valid_targets.clear()

	if is_valid:
		drag_ended.emit(card_data, target, true)
	else:
		global_position = _original_position
		drag_ended.emit(card_data, Vector2i.ZERO, false)


func _update_hover(mouse_pos: Vector2) -> void:
	if not hex_map or not camera:
		return

	# Restore base highlighting — subtle tint for valid targets
	hex_map.clear_highlights()
	hex_map.highlight_tiles(_valid_targets, Color(0.3, 0.8, 1.0, 0.8))

	var hovered := _raycast_hex(mouse_pos)
	if hovered != Vector2i(-999, -999) and _is_valid_target(hovered):
		# Brighter highlight on the hovered hex
		hex_map.highlight_tiles(
			[hovered] as Array[Vector2i],
			Color(1.0, 1.0, 0.3, 1.0),
		)
		# Show arrow from card slot to hovered hex
		if arrow_indicator and camera:
			var from_pos := _screen_to_ground(_original_position + size * 0.5)
			var to_pos := HexUtil.axial_to_world(hovered.x, hovered.y)
			arrow_indicator.show_arrow(from_pos, to_pos)
	else:
		if arrow_indicator:
			arrow_indicator.hide_arrow()


func _raycast_hex(screen_pos: Vector2) -> Vector2i:
	if not hex_map or not camera:
		return Vector2i(-999, -999)
	return hex_map.raycast_to_hex(camera, screen_pos)


func _is_valid_target(coord: Vector2i) -> bool:
	return coord in _valid_targets


func _screen_to_ground(screen_pos: Vector2) -> Vector3:
	var origin := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	if absf(dir.y) < 0.001:
		return Vector3.ZERO
	var t := -origin.y / dir.y
	return origin + dir * t
