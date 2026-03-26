class_name DeckManager
extends RefCounted

var hand_size: int = 5
var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []


func initialize(deck: Array[CardData]) -> void:
	draw_pile = deck.duplicate()
	hand.clear()
	discard_pile.clear()
	draw_pile.shuffle()


func draw_hand() -> void:
	for i in range(hand_size):
		_draw_card()


func play_card(card: CardData) -> bool:
	var idx := hand.find(card)
	if idx == -1:
		return false
	hand.remove_at(idx)
	discard_pile.append(card)
	return true


func discard_hand() -> void:
	discard_pile.append_array(hand)
	hand.clear()


func add_to_discard(card: CardData) -> void:
	discard_pile.append(card)


func count_resources() -> Dictionary:
	var totals := {"food": 0, "materials": 0}
	for pile: Array[CardData] in [draw_pile, hand, discard_pile]:
		for card: CardData in pile:
			if card.card_type != CardData.CardType.RESOURCE:
				continue
			match card.resource_type:
				CardData.ResourceType.FOOD:
					totals["food"] += card.resource_value
				CardData.ResourceType.MATERIALS:
					totals["materials"] += card.resource_value
	return totals


func _draw_card() -> void:
	if draw_pile.is_empty():
		if discard_pile.is_empty():
			return
		_reshuffle_discard()
	if not draw_pile.is_empty():
		var card: CardData = draw_pile.pop_back()
		hand.append(card)


func _reshuffle_discard() -> void:
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()
