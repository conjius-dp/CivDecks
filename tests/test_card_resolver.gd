extends RefCounted

var _plains: TerrainType
var _mountain: TerrainType
var _map: MapData
var _move_card: CardData
var _scout_card: CardData
var _gather_card: CardData
var _settle_card: CardData


func before() -> void:
	_plains = TerrainType.new()
	_plains.terrain_name = "Plains"
	_plains.is_passable = true
	_plains.height = 0.1
	_plains.materials_yield = 1
	_plains.food_yield = 0

	_mountain = TerrainType.new()
	_mountain.terrain_name = "Mountain"
	_mountain.is_passable = false
	_mountain.height = 0.5
	_mountain.materials_yield = 0
	_mountain.food_yield = 0

	_map = MapData.new()
	_map.set_terrain(Vector2i(0, 0), _plains)
	_map.set_terrain(Vector2i(1, 0), _plains)
	_map.set_terrain(Vector2i(2, 0), _plains)
	_map.set_terrain(Vector2i(0, -1), _mountain)
	_map.set_terrain(Vector2i(1, -1), _plains)
	_map.set_terrain(Vector2i(0, 1), _plains)

	_move_card = CardData.new()
	_move_card.card_type = CardData.CardType.MOVE
	_move_card.range_value = 1

	_scout_card = CardData.new()
	_scout_card.card_type = CardData.CardType.SCOUT
	_scout_card.range_value = 2

	_gather_card = CardData.new()
	_gather_card.card_type = CardData.CardType.GATHER
	_gather_card.range_value = 1

	_settle_card = CardData.new()
	_settle_card.card_type = CardData.CardType.SETTLE
	_settle_card.range_value = 0


func test_get_move_targets_excludes_origin() -> void:
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(_move_card, Vector2i(0, 0))
	TestAssert.assert_not_contains(targets, Vector2i(0, 0))


func test_get_move_targets_excludes_impassable() -> void:
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(_move_card, Vector2i(0, 0))
	TestAssert.assert_not_contains(targets, Vector2i(0, -1))


func test_get_move_targets_includes_passable_in_range() -> void:
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(_move_card, Vector2i(0, 0))
	TestAssert.assert_contains(targets, Vector2i(1, 0))
	TestAssert.assert_contains(targets, Vector2i(0, 1))


func test_get_move_targets_excludes_out_of_range() -> void:
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(_move_card, Vector2i(0, 0))
	TestAssert.assert_not_contains(targets, Vector2i(2, 0))


func test_get_scout_targets_only_at_exact_range() -> void:
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(_scout_card, Vector2i(0, 0))
	TestAssert.assert_contains(targets, Vector2i(2, 0))
	TestAssert.assert_not_contains(targets, Vector2i(0, 0))
	TestAssert.assert_not_contains(targets, Vector2i(1, 0))


func test_get_gather_targets() -> void:
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(_gather_card, Vector2i(0, 0))
	TestAssert.assert_contains(targets, Vector2i(1, 0))
	TestAssert.assert_contains(targets, Vector2i(0, 1))
	TestAssert.assert_not_contains(targets, Vector2i(0, -1))


func test_resolve_move_valid() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(_move_card, Vector2i(1, 0), Vector2i(0, 0))
	TestAssert.assert_true(result.success)
	TestAssert.assert_eq(result.new_coord, Vector2i(1, 0))


func test_resolve_move_out_of_range() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(_move_card, Vector2i(2, 0), Vector2i(0, 0))
	TestAssert.assert_false(result.success)


func test_resolve_move_impassable() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(_move_card, Vector2i(0, -1), Vector2i(0, 0))
	TestAssert.assert_false(result.success)


func test_resolve_move_to_self() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(_move_card, Vector2i(0, 0), Vector2i(0, 0))
	TestAssert.assert_false(result.success)


func test_resolve_scout() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(_scout_card, Vector2i(1, 0), Vector2i(0, 0))
	TestAssert.assert_true(result.success)
	TestAssert.assert_gt(result.revealed_tiles.size(), 0)


func test_resolve_gather() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(_gather_card, Vector2i(1, 0), Vector2i(0, 0))
	TestAssert.assert_true(result.success)
	TestAssert.assert_gt(
		result.gained_cards.size(), 0, "gather produces cards"
	)
	var mat_total := 0
	for card: CardData in result.gained_cards:
		TestAssert.assert_eq(
			card.card_type, CardData.CardType.RESOURCE,
			"gained card is RESOURCE type",
		)
		if card.resource_type == CardData.ResourceType.MATERIALS:
			mat_total += card.resource_value
	TestAssert.assert_eq(mat_total, 1, "1 material from plains")


func test_resolve_gather_food_terrain() -> void:
	var forest := TerrainType.new()
	forest.terrain_name = "Forest"
	forest.is_passable = true
	forest.stops_movement = true
	forest.materials_yield = 1
	forest.food_yield = 1
	_map.set_terrain(Vector2i(1, -1), forest)
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(
		_gather_card, Vector2i(1, -1), Vector2i(0, 0)
	)
	TestAssert.assert_true(result.success)
	var food_total := 0
	var mat_total := 0
	for card: CardData in result.gained_cards:
		if card.resource_type == CardData.ResourceType.FOOD:
			food_total += card.resource_value
		elif card.resource_type == CardData.ResourceType.MATERIALS:
			mat_total += card.resource_value
	TestAssert.assert_eq(food_total, 1)
	TestAssert.assert_eq(mat_total, 1)


func test_resolve_gather_cards_are_independent() -> void:
	var resolver := CardResolver.new(_map)
	var r1 := resolver.resolve_card(
		_gather_card, Vector2i(1, 0), Vector2i(0, 0)
	)
	var r2 := resolver.resolve_card(
		_gather_card, Vector2i(1, 0), Vector2i(0, 0)
	)
	if r1.gained_cards.size() > 0 and r2.gained_cards.size() > 0:
		r1.gained_cards[0].resource_value = 999
		TestAssert.assert_eq(
			r2.gained_cards[0].resource_value, 1,
			"mutating one card does not affect another",
		)


func test_resolve_gather_cards_have_correct_fields() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(
		_gather_card, Vector2i(1, 0), Vector2i(0, 0)
	)
	for card: CardData in result.gained_cards:
		TestAssert.assert_eq(
			card.card_type, CardData.CardType.RESOURCE,
		)
		TestAssert.assert_true(
			card.resource_type != CardData.ResourceType.NONE,
			"resource_type is set",
		)
		TestAssert.assert_true(
			card.resource_value > 0, "resource_value > 0"
		)
		TestAssert.assert_true(
			card.card_name.length() > 0, "card has a name"
		)


func test_resolve_gather_no_yield_terrain() -> void:
	var desert := TerrainType.new()
	desert.terrain_name = "Desert"
	desert.is_passable = true
	desert.materials_yield = 0
	desert.food_yield = 0
	_map.set_terrain(Vector2i(1, -1), desert)
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(
		_gather_card, Vector2i(0, 0)
	)
	TestAssert.assert_not_contains(
		targets, Vector2i(1, -1),
		"desert with no yield not a valid gather target",
	)


func test_settle_valid_targets() -> void:
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(
		_settle_card, Vector2i(0, 0)
	)
	TestAssert.assert_size(targets, 1)
	TestAssert.assert_contains(targets, Vector2i(0, 0))


func test_move_into_forest_ends_turn() -> void:
	var forest := TerrainType.new()
	forest.terrain_name = "Forest"
	forest.is_passable = true
	forest.stops_movement = true
	forest.materials_yield = 1
	forest.food_yield = 1
	_map.set_terrain(Vector2i(1, -1), forest)
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(
		_move_card, Vector2i(1, -1), Vector2i(0, 0)
	)
	TestAssert.assert_true(result.success)
	TestAssert.assert_true(result.ends_turn)


func test_move_into_plains_does_not_end_turn() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(
		_move_card, Vector2i(1, 0), Vector2i(0, 0)
	)
	TestAssert.assert_true(result.success)
	TestAssert.assert_false(result.ends_turn)


func test_settle_on_impassable_returns_empty() -> void:
	var resolver := CardResolver.new(_map)
	var targets := resolver.get_valid_targets(
		_settle_card, Vector2i(0, -1)
	)
	TestAssert.assert_size(targets, 0)


func test_resolve_settle() -> void:
	var resolver := CardResolver.new(_map)
	var result := resolver.resolve_card(
		_settle_card, Vector2i(0, 0), Vector2i(0, 0)
	)
	TestAssert.assert_true(result.success)
	TestAssert.assert_eq(result.settled_coord, Vector2i(0, 0))
	TestAssert.assert_true(result.settlement_name.length() > 0)


func test_settle_twice_fails() -> void:
	var resolver := CardResolver.new(_map)
	resolver.resolve_card(
		_settle_card, Vector2i(0, 0), Vector2i(0, 0)
	)
	var result := resolver.resolve_card(
		_settle_card, Vector2i(0, 0), Vector2i(0, 0)
	)
	TestAssert.assert_false(result.success)
