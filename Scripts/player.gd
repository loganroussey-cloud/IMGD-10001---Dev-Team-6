extends CharacterBody2D

signal health_depleted
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

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed

	move_and_slide()
	
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()
	
	# Taking damage
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
		#set speed
		#start timer
		#0.5s
		#end timer
		#set immunity back
		#set speed back
