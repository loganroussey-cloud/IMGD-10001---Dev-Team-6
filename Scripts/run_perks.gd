extends Node

signal perks_updated

var speed_bonus := 0.0
var max_health_bonus := 0.0
var damage_bonus := 0
var fire_rate_multiplier := 1.0

var owned_perks : Array = []

func reset():
	speed_bonus = 0.0
	max_health_bonus = 0.0
	damage_bonus = 0
	fire_rate_multiplier = 1.0
	owned_perks.clear()

func add_perk(perk_name: String):
	owned_perks.append(perk_name)

	match perk_name:
		"Speed":
			speed_bonus += 100
		"Damage":
			damage_bonus += 1
		"Health":
			max_health_bonus += 25
		"Fire Rate":
			fire_rate_multiplier *= 0.9

	emit_signal("perks_updated")
