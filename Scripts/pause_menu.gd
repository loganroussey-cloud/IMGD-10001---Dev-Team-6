extends Control
@onready var sketch_man: CharacterBody2D = $"../sketch_man"
@onready var game: Node2D = $".."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sketch_man = get_node("../sketch_man")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = sketch_man.position

func _on_resume_pressed() -> void:
	game.close_pause()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_backto_title_pressed() -> void:
	game.close_pause()
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
