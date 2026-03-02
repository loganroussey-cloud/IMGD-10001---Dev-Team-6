extends CharacterBody2D

signal health_depleted
var last_animation = "north"
var is_moving = false
var dashing = false

var health = 100.0
var speed = 600.0

const BASE_SPEED = 500
const BASE_HEALTH = 100
var max_health = BASE_HEALTH

func apply_perks():
	max_health = BASE_HEALTH + RunPerks.max_health_bonus

	# Fully heal when max health increases
	health = max_health

	%HealthBar.max_value = max_health
	%HealthBar.value = health

	speed = BASE_SPEED + RunPerks.speed_bonus

func _ready():
	RunPerks.perk_added.connect(apply_perks)
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
	
	if dashing == false:
		if direction != Vector2.ZERO:
			if not is_moving:
				is_moving = true
			last_animation = get_direction_name(direction)
			%PlayerAnimation.play(last_animation)
		else:
			if is_moving:
				is_moving = false
				%PlayerAnimation.play(last_animation + "idle")

	# Passive regen
	if RunPerks.regen_per_second > 0 and health < max_health:
		health += RunPerks.regen_per_second * delta
		health = clamp(health, 0, max_health)
		%HealthBar.value = health

	const DAMAGE_RATE = 6.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0 and not dashing:
		# Player takes damage
		var incoming = DAMAGE_RATE * overlapping_mobs.size() * delta
		incoming *= (1.0 - RunPerks.damage_reduction)
		health -= incoming
		%HealthBar.value = health
		# Thorns damage back to enemies
		if RunPerks.thorns_damage > 0:
			for mob in overlapping_mobs:
				if mob.has_method("take_damage"):
					mob.take_damage(RunPerks.thorns_damage * delta)

		if health <= 0.0:
			health_depleted.emit()

func _process(_delta):
	if Input.is_action_pressed("dash")&&(!dashing)&&(velocity.length()!=0):
			print(str(speed) + "this speed")
			dashing = true
			#var tempHealth = health
			var tempSpeed = speed
			speed = speed * 3
			modulate = Color(1.0, 1.0, 1.0, 0.0)
			await get_tree().create_timer(0.3).timeout #change time here for dash duration
			#health = tempHealth
			modulate = Color(0.605, 0.684, 1.0, 1.0)
			%PlayerAnimation.play(last_animation + "idle")
			%PlayerAnimation.frame = 0
			%PlayerAnimation.stop()
			while speed>tempSpeed:
				speed -= 300
				await get_tree().create_timer(0.025).timeout
			%PlayerAnimation.play(last_animation)
			speed = tempSpeed
			await get_tree().create_timer(0.2).timeout #change time here for dash cooldown
			modulate = Color(1.0, 1.0, 1.0, 1.0)
			dashing = false
			
func heal(amount):
	health = clamp(health + amount, 0, max_health)
	%HealthBar.value = health
