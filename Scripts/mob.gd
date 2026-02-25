extends CharacterBody2D


var speed = randf_range(200, 300)
var health = 5

@onready var score_board
@onready var sketch_man = get_node("/root/Game/sketch_man")

func _ready():
	%Slime.play_walk()

func _physics_process(_delta):
	var direction = global_position.direction_to(sketch_man.global_position)
	velocity = direction * speed
	move_and_slide()

func take_damage(amount = 1):
	%Slime.play_hurt()
	health -= amount

	if health <= 0:
		var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		#score_board.add_kc()
		#speed = 0
		#%Slime.play_dead()
		#if overlapping_withplayer:
		#	score_board.addshaving(5)
		#	queue_free()
		
		queue_free()
		GameEvents.enemy_killed()
