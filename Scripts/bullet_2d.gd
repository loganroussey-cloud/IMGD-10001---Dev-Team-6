extends Area2D


var travelled_distance = 0
var base_damage := 1

func _physics_process(delta):
	const SPEED = 1000
	const RANGE = 1200

	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body):
	var final_damage = base_damage + RunPerks.damage_bonus
	if randf() < RunPerks.crit_chance:
		final_damage *= 2.0
	if body.has_method("take_damage"):
		body.take_damage(final_damage)

	queue_free()
