extends Node2D
@onready var score_board = $score_board
@onready var pause_menu = $pause_menu
var paused = false
#var scoreboardOpen = false

#pauses game
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
#hold to show scoreboard
	if Input.is_action_pressed("scoreboard"):
		score_board.show()
	else:
		score_board.hide()
		#scoreboardOpen = !scoreboardOpen
		

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
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
