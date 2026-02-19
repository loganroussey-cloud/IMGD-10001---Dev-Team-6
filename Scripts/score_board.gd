extends Control

var wrathkc = 0
var shavings = 0
var gold = 0
var coal = 0
@onready var player: CharacterBody2D = $"../Player"
@onready var label: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = player.position + Vector2(-500,-300)



#func add_kc():
	#wrathkc += 1
	#update_label()
func add_gold():
	gold += 1
	update_label()
func add_coal():
	coal += 1
	update_label()
func update_label():
	label.text = "gold: " + str(gold) + "\ncoal: " + str(coal)
	#when kc or gold or coal func is called, update the label with all
#func add_shaving(amt):
#	shavings += amt
#	label.text = "shavings: " + str(shavings)
	
