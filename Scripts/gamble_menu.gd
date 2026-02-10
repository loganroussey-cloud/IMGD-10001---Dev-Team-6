extends Control

@onready var player: CharacterBody2D = $"../Player"
@onready var gamble_screen: Control = $"."
@onready var texture_button: TextureButton = $TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_button.pressed.connect(_on_texture_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = player.position + Vector2(-550,-320)


func _on_texture_button_pressed():
	print("machine spun")
