extends Node

signal perk_added

var speed_bonus := 0.0
var max_health_bonus := 0.0
var damage_bonus := 0
var fire_rate_bonus := 1.0
var lifesteal_percent := 0.0
var thorns_damage := 0.0
var regen_per_second := 0.0
var crit_chance := 0.0
var damage_reduction := 0.0

var owned_perks : Array = []

func reset():
	speed_bonus = 0.0
	max_health_bonus = 0.0
	damage_bonus = 0
	fire_rate_bonus = 1.0
	lifesteal_percent = 0.0
	thorns_damage = 0.0
	regen_per_second = 0.0
	crit_chance = 0.0
	damage_reduction = 0.0
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
			fire_rate_bonus += 0.1
		"Life Steal":
			lifesteal_percent += 0.1   # +10% per stack
		"Thorns":
			thorns_damage += 2.0
		"Regen":
			regen_per_second += 2.0
		"Crit Chance":
			crit_chance += 0.05   # +5% per stack
		"Armor":
			damage_reduction += 0.05
			
	emit_signal("perk_added")


func get_perk_counts() -> Dictionary:
	var counts: Dictionary = {}
	for p in owned_perks:
		var key := str(p) # should be "Speed", "Damage", etc.
		counts[key] = counts.get(key, 0) + 1
	return counts
