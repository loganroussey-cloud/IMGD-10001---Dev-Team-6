extends Node2D
@onready var score_board = $score_board
@onready var pause_menu = $pause_menu
@onready var gamble_menu = $gamble_menu
var paused = false

#pauses game
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	if Input.is_action_just_pressed("inventory"):
		pauseInventory()


func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused

func pauseInventory():
	if paused:
		gamble_menu.hide()
		Engine.time_scale = 1
	else:
		gamble_menu.show()
		Engine.time_scale = 0
		
	paused = !paused

func spawn_mob():
	%PathFollow2D.progress_ratio = randf()
	var new_mob = preload("res://characters/mob.tscn").instantiate()
	new_mob.global_position = %PathFollow2D.global_position
	new_mob.score_board = score_board
	add_child(new_mob)


func _on_timer_timeout():
	spawn_mob()


func _on_player_health_depleted():
	%GameOver.show()
	get_tree().paused = true
