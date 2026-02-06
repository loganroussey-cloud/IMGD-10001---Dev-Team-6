extends Control

var wrathkc = 0
var shavings = 0
@onready var player: CharacterBody2D = $"../Player"
@onready var label: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = player.position + Vector2(-500,-300)



func add_kc():
	wrathkc += 1
	label.text = "wrath monsters killed: " + str(wrathkc)
func add_shaving(amt):
	shavings += amt
	label.text = "shavings: " + str(shavings)
	
