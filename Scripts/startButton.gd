extends Button


# Called when the node enters the scene tree for the first time.


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://survivors_game.tscn")


func _on_versionlog_pressed() -> void:
	get_tree().change_scene_to_file("res://survivors_game.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://survivors_game.tscn")
