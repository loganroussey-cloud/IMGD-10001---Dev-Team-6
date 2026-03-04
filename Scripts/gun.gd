extends Area2D
@onready var timer = $Timer

func _process(_delta):
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)

const BASE_DAMAGE = 1
const BASE_FIRE_RATE = 0.5
var damage = BASE_DAMAGE
var fire_rate = BASE_FIRE_RATE

func apply_perks():

	damage = BASE_DAMAGE + RunPerks.damage_bonus
	fire_rate = BASE_FIRE_RATE / (1.0 + RunPerks.fire_rate_bonus)
	
	$Timer.wait_time = fire_rate

func _ready():
	RunPerks.perk_added.connect(apply_perks)
	apply_perks()

func shoot():
	const BULLET = preload("res://pistol/bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = %ShootingPoint.global_transform
	%ShootingPoint.add_child(new_bullet)
	var new_throw = preload("res://Scenes/throw_sound.tscn").instantiate()
	add_child(new_throw)

func _on_timer_timeout() -> void:
	shoot()
