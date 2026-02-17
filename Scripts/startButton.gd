extends Button

# Called when the node enters the scene tree for the first time.


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/survivors_game.tscn")
	Engine.time_scale = 1


func _on_versionlog_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/version_log.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits_screen.tscn")
