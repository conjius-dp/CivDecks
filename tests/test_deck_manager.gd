extends RefCounted

var _card_a: CardData
var _card_b: CardData
var _card_c: CardData


var _food_card: CardData
var _mat_card: CardData


func before() -> void:
	_card_a = CardData.new()
	_card_a.card_name = "A"
	_card_b = CardData.new()
	_card_b.card_name = "B"
	_card_c = CardData.new()
	_card_c.card_name = "C"
	_food_card = CardData.new()
	_food_card.card_name = "Chicken"
	_food_card.card_type = CardData.CardType.RESOURCE
	_food_card.resource_type = CardData.ResourceType.FOOD
	_food_card.resource_value = 1
	_mat_card = CardData.new()
	_mat_card.card_name = "Wood"
	_mat_card.card_type = CardData.CardType.RESOURCE
	_mat_card.resource_type = CardData.ResourceType.MATERIALS
	_mat_card.resource_value = 1


func _make_deck(cards: Array[CardData], hand_size: int = 5) -> DeckManager:
	var dm := DeckManager.new()
	dm.hand_size = hand_size
	dm.initialize(cards)
	return dm


func test_initialize_deck() -> void:
	var deck: Array[CardData] = [_card_a, _card_b, _card_c]
	var dm := _make_deck(deck)
	TestAssert.assert_eq(dm.draw_pile.size(), 3)
	TestAssert.assert_size(dm.hand, 0)
	TestAssert.assert_size(dm.discard_pile, 0)


func test_draw_hand() -> void:
	var deck: Array[CardData] = [_card_a, _card_b, _card_c]
	var dm := _make_deck(deck, 2)
	dm.draw_hand()
	TestAssert.assert_size(dm.hand, 2)
	TestAssert.assert_eq(dm.draw_pile.size(), 1)


func test_draw_hand_all_cards() -> void:
	var deck: Array[CardData] = [_card_a, _card_b, _card_c]
	var dm := _make_deck(deck, 5)
	dm.draw_hand()
	TestAssert.assert_size(dm.hand, 3)
	TestAssert.assert_size(dm.draw_pile, 0)


func test_play_card() -> void:
	var deck: Array[CardData] = [_card_a, _card_b]
	var dm := _make_deck(deck, 2)
	dm.draw_hand()
	var played := dm.play_card(_card_a)
	TestAssert.assert_true(played)
	TestAssert.assert_size(dm.hand, 1)
	TestAssert.assert_contains(dm.discard_pile, _card_a)


func test_play_card_not_in_hand() -> void:
	var deck: Array[CardData] = [_card_a]
	var dm := _make_deck(deck, 1)
	dm.draw_hand()
	var played := dm.play_card(_card_b)
	TestAssert.assert_false(played)
	TestAssert.assert_size(dm.hand, 1)


func test_discard_hand() -> void:
	var deck: Array[CardData] = [_card_a, _card_b]
	var dm := _make_deck(deck, 2)
	dm.draw_hand()
	dm.discard_hand()
	TestAssert.assert_size(dm.hand, 0)
	TestAssert.assert_eq(dm.discard_pile.size(), 2)


func test_draw_hand_reshuffles_discard() -> void:
	var deck: Array[CardData] = [_card_a, _card_b, _card_c]
	var dm := _make_deck(deck, 3)
	dm.draw_hand()
	TestAssert.assert_size(dm.hand, 3)
	dm.discard_hand()
	TestAssert.assert_size(dm.discard_pile, 3)
	TestAssert.assert_size(dm.draw_pile, 0)
	dm.draw_hand()
	TestAssert.assert_size(dm.hand, 3)
	TestAssert.assert_size(dm.discard_pile, 0)


func test_add_to_discard() -> void:
	var deck: Array[CardData] = [_card_a]
	var dm := _make_deck(deck, 1)
	dm.add_to_discard(_food_card)
	TestAssert.assert_size(dm.discard_pile, 1)
	TestAssert.assert_contains(dm.discard_pile, _food_card)


func test_add_to_discard_enters_rotation() -> void:
	var deck: Array[CardData] = [_card_a]
	var dm := _make_deck(deck, 5)
	dm.draw_hand()
	dm.add_to_discard(_food_card)
	dm.discard_hand()
	dm.draw_hand()
	TestAssert.assert_size(dm.hand, 2)


func test_count_resources_empty() -> void:
	var deck: Array[CardData] = [_card_a]
	var dm := _make_deck(deck)
	var totals: Dictionary = dm.count_resources()
	TestAssert.assert_eq(totals["food"], 0)
	TestAssert.assert_eq(totals["materials"], 0)


func test_count_resources_in_discard() -> void:
	var deck: Array[CardData] = [_card_a]
	var dm := _make_deck(deck)
	dm.add_to_discard(_food_card)
	dm.add_to_discard(_mat_card)
	var totals: Dictionary = dm.count_resources()
	TestAssert.assert_eq(totals["food"], 1)
	TestAssert.assert_eq(totals["materials"], 1)


func test_count_resources_across_all_piles() -> void:
	var deck: Array[CardData] = [_food_card, _mat_card, _card_a]
	var dm := _make_deck(deck, 2)
	dm.draw_hand()
	dm.add_to_discard(_food_card)
	var totals: Dictionary = dm.count_resources()
	TestAssert.assert_true(
		totals["food"] >= 1, "food found in at least one pile"
	)


func test_count_resources_sums_values() -> void:
	var high_food := CardData.new()
	high_food.card_type = CardData.CardType.RESOURCE
	high_food.resource_type = CardData.ResourceType.FOOD
	high_food.resource_value = 3
	var deck: Array[CardData] = [_card_a]
	var dm := _make_deck(deck)
	dm.add_to_discard(_food_card)
	dm.add_to_discard(high_food)
	var totals: Dictionary = dm.count_resources()
	TestAssert.assert_eq(totals["food"], 4)
