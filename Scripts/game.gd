extends Node2D
@onready var score_board = $score_board
@onready var pause_menu = $pause_menu
@onready var gamble_menu = $gamble_menu
@onready var progress_bar = $CanvasLayer/ProgressBar
@export var boss_scene: PackedScene

var paused = false

var kills := 0
var kills_to_boss := 10
var boss_spawned := false
var all_perks = ["Speed", "Damage", "Health", "Fire Rate"]

var current_wave := 1

var enemies_spawned := 0
var enemies_killed := 0

var enemies_to_spawn := 10
var enemies_to_kill := 10

var boss_active := false

#pauses game
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	if Input.is_action_just_pressed("inventory"):
		pauseInventory()

func _ready():
	randomize()
	RunPerks.reset()

	RunPerks.speed_bonus = 200
	RunPerks.max_health_bonus = 50
	RunPerks.damage_bonus = 2
	RunPerks.fire_rate_multiplier = 1

	var player = $Player
	player.apply_perks()

	var gun = player.get_node("Gun")
	gun.apply_perks()
	
	GameEvents.enemy_killed_signal.connect(_on_enemy_killed)

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
	if boss_active:
		return
		
	if enemies_spawned >= enemies_to_spawn:
		return
	
	spawn_mob()
	enemies_spawned += 1

func _on_player_health_depleted():
	%GameOver.show()
	get_tree().paused = true
	
func _on_enemy_killed():

	if boss_active:
		return
		
	enemies_killed += 1
	
	progress_bar.value = float(enemies_killed) / enemies_to_kill * 100
	
	if enemies_killed >= enemies_to_kill:
		call_deferred("spawn_boss")

func spawn_boss():
	boss_active = true
	$Mob_Spawn_Timer.stop()
	
	var boss = boss_scene.instantiate()
	boss.global_position = %PathFollow2D.global_position
	add_child.call_deferred(boss)

	GameEvents.boss_killed.connect(_on_boss_killed)
	
func _on_boss_killed():
	show_perk_choices()
	
	start_next_wave()
	
func show_perk_choices():
	var choices = []
	var pool = all_perks.duplicate()
	
	for i in 3:
		var index = randi() % pool.size()
		choices.append(pool[index])
		pool.remove_at(index)
	
	print("Choose one:", choices)
	
	RunPerks.add_perk(choices[0])
	
	reset_boss_cycle()

func reset_boss_cycle():
	kills = 0
	progress_bar.value = 0
	boss_spawned = false
	
func start_next_wave():

	current_wave += 1
	
	enemies_spawned = 0
	enemies_killed = 0
	
	enemies_to_spawn += 5
	enemies_to_kill += 5
	
	progress_bar.value = 0
	
	boss_active = false
	
	$Mob_Spawn_Timer.start()
