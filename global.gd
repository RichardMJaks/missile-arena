extends Node

var p1_score: int = 0
var p2_score: int = 0

signal death_happened(player: int)

func death(player: int) -> void:
	if player == 0:
		p2_score += 1
	if player == 1:
		p1_score += 1

	death_happened.emit(player)
	
