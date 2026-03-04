extends Node2D

@onready var damage_sfx = $AudioStreamPlayer2DDamage

func _ready():
	damage_sfx.pitch_scale = randf_range(0.8,1.5)
	damage_sfx.play()
	await damage_sfx.finished
	queue_free()
