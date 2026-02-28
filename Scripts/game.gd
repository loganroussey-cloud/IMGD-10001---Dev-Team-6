extends Node2D
@onready var score_board = $score_board
@onready var pause_menu = $pause_menu
@onready var gamble_menu = $gamble_menu
@onready var progress_bar = $UI/ProgressBar
@export var boss_scene: PackedScene
@onready var death_menu = $death_menu
@onready var perk_notification = $UI/PerkNotification

var all_perks = ["Speed", "Damage", "Health", "Fire Rate",
 				"Life Steal", "Thorns", "Regen", "Crit Chance", "Armor"]

var enemies_spawned := 0
var enemies_killed := 0

var enemies_to_spawn := 10
var enemies_to_kill := 10

var boss_active := false

enum MenuState {
	NONE,
	INVENTORY,
	PAUSE
}

var current_menu_state : MenuState = MenuState.NONE

func _ready():
	pause_menu.visible = false
	gamble_menu.visible = false
	
	randomize()
	RunPerks.reset()
	
	RunPerks.add_perk("Speed")
	RunPerks.add_perk("Health")
	RunPerks.add_perk("Damage")

	var player = $sketch_man
	player.apply_perks()

	var gun = player.get_node("Gun")
	gun.apply_perks()
	
	GameEvents.enemy_killed_signal.connect(_on_enemy_killed)
	GameEvents.boss_killed.connect(_on_boss_killed)

func set_menu_state(new_state : MenuState):
	current_menu_state = new_state
	
	# Hide everything first
	gamble_menu.visible = false
	pause_menu.visible = false
	
	match current_menu_state:
		MenuState.NONE:
			get_tree().paused = false
		
		MenuState.INVENTORY:
			gamble_menu.visible = true
			get_tree().paused = true
		
		MenuState.PAUSE:
			pause_menu.visible = true
			get_tree().paused = true

func on_resume_button_pressed():
	pause_menu.visible = false
	get_tree().paused = false

func toggle_pause_menu():
	if current_menu_state == MenuState.PAUSE:
		set_menu_state(MenuState.NONE)
	else:
		set_menu_state(MenuState.PAUSE)

func toggle_inventory_menu():
	if current_menu_state == MenuState.INVENTORY:
		set_menu_state(MenuState.NONE)
	elif current_menu_state == MenuState.PAUSE:
		return
	else:
		set_menu_state(MenuState.INVENTORY)
			
func open_pause():
	pause_menu.visible = true
	get_tree().paused = true

func close_pause():
	pause_menu.visible = false
	get_tree().paused = false

func open_inventory():
	gamble_menu.visible = true
	get_tree().paused = true

func close_inventory():
	gamble_menu.visible = false
	get_tree().paused = false

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
	get_tree().change_scene_to_file("res://Scenes/death_menu.tscn")
	
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

	# Apply perks
	for perk in choices:
		RunPerks.add_perk(perk)

	# Show ALL perks in one notification
	perk_notification.show_multiple_perks(choices)

	boss_active = false
	
func start_next_wave():
	
	enemies_spawned = 0
	enemies_killed = 0
	
	enemies_to_spawn += 5
	enemies_to_kill += 5
	
	progress_bar.value = 0
	
	$Mob_Spawn_Timer.start()
