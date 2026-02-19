extends Area2D
@onready var timer = $Timer
var base_fire_rate := 0.5

func _process(_delta):
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)

func apply_perks():
	timer.wait_time = base_fire_rate * RunPerks.fire_rate_multiplier
	timer.start()

func _ready():
	timer.wait_time = base_fire_rate
	RunPerks.perks_updated.connect(apply_perks)
	apply_perks()

func shoot():
	const BULLET = preload("res://pistol/bullet_2d.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_transform = %ShootingPoint.global_transform
	%ShootingPoint.add_child(new_bullet)


func _on_timer_timeout() -> void:
	shoot()
