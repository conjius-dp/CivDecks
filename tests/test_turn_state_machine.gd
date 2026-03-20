extends RefCounted


func _make_tsm(max_cards: int = 3) -> TurnStateMachine:
	var tsm := TurnStateMachine.new()
	tsm.max_cards_per_turn = max_cards
	return tsm


func test_start_game() -> void:
	var tsm := _make_tsm()
	tsm.start_game()
	TestAssert.assert_eq(tsm.current_turn, 1)
	TestAssert.assert_eq(tsm.current_phase, TurnStateMachine.Phase.PLAY)
	TestAssert.assert_eq(tsm.cards_played_this_turn, 0)


func test_can_play_cards() -> void:
	var tsm := _make_tsm()
	tsm.start_game()
	TestAssert.assert_true(tsm.can_play_cards())


func test_on_card_played_increments() -> void:
	var tsm := _make_tsm()
	tsm.start_game()
	var result := tsm.on_card_played()
	TestAssert.assert_eq(tsm.cards_played_this_turn, 1)
	TestAssert.assert_false(result.turn_ended)


func test_on_card_played_max_triggers_end() -> void:
	var tsm := _make_tsm(2)
	tsm.start_game()
	tsm.on_card_played()
	var result := tsm.on_card_played()
	TestAssert.assert_true(result.turn_ended)


func test_end_turn() -> void:
	var tsm := _make_tsm()
	tsm.start_game()
	tsm.on_card_played()
	var result := tsm.end_turn()
	TestAssert.assert_true(result.turn_ended)
	TestAssert.assert_eq(tsm.current_turn, 2)
	TestAssert.assert_eq(tsm.cards_played_this_turn, 0)
	TestAssert.assert_eq(tsm.current_phase, TurnStateMachine.Phase.PLAY)


func test_end_turn_not_in_play_phase() -> void:
	var tsm := _make_tsm()
	var result := tsm.end_turn()
	TestAssert.assert_false(result.turn_ended)


func test_auto_end_starts_new_turn_where_play_is_allowed() -> void:
	var tsm := _make_tsm(1)
	tsm.start_game()
	var result := tsm.on_card_played()
	TestAssert.assert_true(result.turn_ended)
	TestAssert.assert_eq(tsm.current_turn, 2)
	TestAssert.assert_true(tsm.can_play_cards())
