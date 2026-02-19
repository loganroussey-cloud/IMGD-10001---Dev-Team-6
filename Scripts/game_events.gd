extends Node

signal enemy_killed_signal
signal boss_killed

func enemy_killed():
	emit_signal("enemy_killed_signal")
