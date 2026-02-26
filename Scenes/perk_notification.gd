extends Control

var current_tween: Tween
var offscreen_offset := 500
var resting_x: float
var original_card_positions := []

@onready var cards := [
	$VBoxContainer/PerkCard1,
	$VBoxContainer/PerkCard2,
	$VBoxContainer/PerkCard3
]

@onready var labels := [
	$VBoxContainer/PerkCard1/Perk1,
	$VBoxContainer/PerkCard2/Perk2,
	$VBoxContainer/PerkCard3/Perk3
]

func _ready():
	hide()
	resting_x = global_position.x

	for card in cards:
		original_card_positions.append(card.position)

func show_multiple_perks(perks: Array):

	for i in labels.size():
		labels[i].text = "+ " + str(perks[i]) if perks.size() > i else ""

	if current_tween and current_tween.is_running():
		current_tween.kill()

	show()
	modulate.a = 1.0
	global_position.x = resting_x + offscreen_offset

	# Reset cards
	for card in cards:
		card.modulate = Color(1, 1, 1, 0.0)
		card.scale = Vector2.ONE * 0.8

	current_tween = get_tree().create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_BACK)

	# Panel slam in
	current_tween.tween_property(self, "global_position:x", resting_x, 0.35)

	# Staggered powerful pop
	for i in cards.size():
		current_tween.tween_interval(0.1)

		current_tween.parallel().tween_property(cards[i], "modulate:a", 1.0, 0.15)
		current_tween.parallel().tween_property(cards[i], "modulate:a", 1.0, 0.2)
		current_tween.parallel().tween_property(cards[i], "scale", Vector2.ONE, 0.25)
		current_tween.parallel().tween_property(cards[i], "scale", Vector2.ONE * 1.1, 0.15)

		# snap back to normal scale
		current_tween.parallel().tween_property(cards[i], "scale", Vector2.ONE, 0.15)

	# Hold
	current_tween.tween_interval(3.0)

	# Fade out cleanly
	current_tween.set_trans(Tween.TRANS_CUBIC)
	current_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	current_tween.tween_callback(hide)
