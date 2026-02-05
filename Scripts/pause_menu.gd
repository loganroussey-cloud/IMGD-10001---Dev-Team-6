extends Control

@onready var game: Node2D = $".."
@onready var player: CharacterBody2D = $"../Player"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("../Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = player.position



func _on_resume_pressed() -> void:
	game.pauseMenu()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_backto_title_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
