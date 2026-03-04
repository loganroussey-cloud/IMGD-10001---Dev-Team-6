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

func _reset_bonuses_only() -> void:
	speed_bonus = 0.0
	max_health_bonus = 0.0
	damage_bonus = 0
	fire_rate_bonus = 1.0
	lifesteal_percent = 0.0
	thorns_damage = 0.0
	regen_per_second = 0.0
	crit_chance = 0.0
	damage_reduction = 0.0

func reset() -> void:
	_reset_bonuses_only()
	owned_perks.clear()

func _apply_bonus(perk_name: String) -> void:
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

func add_perk(perk_name: String) -> void:
	owned_perks.append(perk_name)
	_apply_bonus(perk_name)
	emit_signal("perk_added")

# Add N stacks at once and emit perk_added once (so UI/stats update cleanly)
func add_perk_stacks(perk_name: String, stacks: int) -> void:
	stacks = maxi(stacks, 0)
	if stacks == 0:
		return
	for i in range(stacks):
		owned_perks.append(perk_name)
		_apply_bonus(perk_name)
	emit_signal("perk_added")

# Remove every stack of perk_name, rebuild bonuses from remaining owned_perks, emit once
func remove_all_perks(perk_name: String) -> void:
	var name_str := str(perk_name)
	owned_perks = owned_perks.filter(func(p): return str(p) != name_str)
	_rebuild_from_owned()
	emit_signal("perk_added")

func _rebuild_from_owned() -> void:
	_reset_bonuses_only()
	for p in owned_perks:
		_apply_bonus(str(p))

func get_perk_counts() -> Dictionary:
	var counts: Dictionary = {}
	for p in owned_perks:
		var key := str(p)
		counts[key] = counts.get(key, 0) + 1
	return counts
