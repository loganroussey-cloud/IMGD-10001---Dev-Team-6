extends CharacterBody2D


var speed = randf_range(200, 300)
var health = 5
var is_dead = false


@onready var score_board
@onready var sketch_man = get_node("/root/Game/sketch_man")


func _ready():
	%Slime.play_walk()

func _physics_process(_delta):
	if !is_dead:
		var direction = global_position.direction_to(sketch_man.global_position)
		velocity = direction * speed
		move_and_slide()

func take_damage(amount = 1):
	if !is_dead:
		%Slime.play_hurt()

		health -= amount
		var new_hit = preload("res://Scenes/damage_sound.tscn").instantiate()
		add_child(new_hit)

	 #Apply lifesteal
	var lifesteal = RunPerks.lifesteal_percent
	if lifesteal > 0:
		var heal_amount = amount * lifesteal
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.heal(heal_amount)

	if health <= 0:
		var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position

		queue_free()
		GameEvents.enemy_killed()

	if health <= 0:
		var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		is_dead = true
		modulate = Color(0,0,0,0)
		#$CollisionShape2D.disabled = true
		#score_board.add_kc()
		#speed = 0
		#%Slime.play_dead()
		#if overlapping_withplayer:
		#	score_board.addshaving(5)
		#	queue_free()
		var new_death = preload("res://Scenes/death_sound.tscn").instantiate()
		add_child(new_death)
		await get_tree().create_timer(1.2).timeout
		queue_free()
		GameEvents.enemy_killed()
