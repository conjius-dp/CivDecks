class_name TurnStateMachine
extends RefCounted

enum Phase { DRAW, PLAY, CLEANUP }

var max_cards_per_turn: int = 3
var current_turn: int = 0
var current_phase: Phase = Phase.DRAW
var cards_played_this_turn: int = 0


class TurnResult extends RefCounted:
	var turn_ended: bool = false
	var new_turn: int = 0


func start_game() -> void:
	current_turn = 0
	_start_new_turn()


func on_card_played() -> TurnResult:
	cards_played_this_turn += 1
	var result := TurnResult.new()
	if cards_played_this_turn >= max_cards_per_turn:
		_end_current_turn()
		result.turn_ended = true
		result.new_turn = current_turn
	return result


func end_turn() -> TurnResult:
	var result := TurnResult.new()
	if current_phase != Phase.PLAY:
		return result
	_end_current_turn()
	result.turn_ended = true
	result.new_turn = current_turn
	return result


func can_play_cards() -> bool:
	return current_phase == Phase.PLAY and cards_played_this_turn < max_cards_per_turn


func _start_new_turn() -> void:
	current_turn += 1
	cards_played_this_turn = 0
	current_phase = Phase.PLAY


func _end_current_turn() -> void:
	current_phase = Phase.CLEANUP
	_start_new_turn()
