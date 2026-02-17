extends Control

@onready var score_board: Control = $"../score_board"
@onready var player: CharacterBody2D = $"../Player"
@onready var gamble_screen: Control = $"."
@onready var texture_button: TextureButton = $TextureButton
var low_endroll = 1
var high_endroll = 10

func _ready() -> void:
	texture_button.pressed.connect(_on_texture_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = player.position + Vector2(-550,-320)


func _on_texture_button_pressed():
	if (score_board.wrathkc >= 2 && high_endroll >= 1):
		high_endroll -= 1
	if (randi_range(low_endroll, high_endroll) == 1):
		score_board.add_gold()
		print("you got +1 gold!")
		print("highroll: " + str(high_endroll))
	else:
		score_board.add_coal()
		print("you got +1 coal...")
		print("highroll: " + str(high_endroll))
	
