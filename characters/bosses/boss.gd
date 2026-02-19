extends CharacterBody2D

var health := 50
var speed = randf_range(200, 300)

@onready var score_board
@onready var player = get_node("/root/Game/Player")

func _ready():
	%BossArt.play_walk()

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func die():
	GameEvents.emit_signal("boss_killed")
	queue_free()

func take_damage(amount = 1):
	%BossArt.play_hurt()
	health -= amount
	if health <= 0:
		die()

	if health <= 0:
		var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = smoke_scene.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		#score_board.add_kc()
		
		queue_free()
		GameEvents.enemy_killed()
