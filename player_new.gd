extends CharacterBody2D

signal health_depleted
var last_animation = "north"
var is_moving = false
var dashing = false
var base_health = 100.0
var base_speed = 600.0

var health = 100.0
var speed = 600.0

func apply_perks():
	speed = base_speed + RunPerks.speed_bonus
	health = base_health + RunPerks.max_health_bonus

func _ready():
	RunPerks.perks_updated.connect(apply_perks)
	apply_perks()
	

func get_direction_name(direction: Vector2) -> String:
	var x = direction.x
	var y = direction.y
	if abs(x) > 0.3 and abs(y) > 0.3:
		%PlayerAnimation.flip_h = x > 0
		return "northwest" if y < 0 else "southwest"
	elif abs(x) > abs(y):
		%PlayerAnimation.flip_h = x > 0
		return "west"
	else:
		%PlayerAnimation.flip_h = false
		return "south" if y > 0 else "north"



func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed

	move_and_slide()
	
	if direction != Vector2.ZERO:
		if not is_moving:
			is_moving = true
		last_animation = get_direction_name(direction)
		%PlayerAnimation.play(last_animation)
	else:
		if is_moving:
			is_moving = false
			%PlayerAnimation.play(last_animation + "idle")



	const DAMAGE_RATE = 6.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		if health <= 0.0:
			health_depleted.emit()

func _process(_delta):
	if Input.is_action_pressed("dash")&&(!dashing)&&(velocity.length()!=0):
			dashing = true
			var tempHealth = health
			health = INF
			speed = 1600.0
			modulate = Color(0.026, 0.125, 0.495, 1.0)
			await get_tree().create_timer(0.3).timeout #change time here for dash duration
			health = tempHealth
			speed = 600.0
			modulate = Color(0.605, 0.684, 1.0, 1.0)
			await get_tree().create_timer(1.0).timeout #change time here for dash cooldown
			modulate = Color(1.0, 1.0, 1.0, 1.0)
			dashing = false
