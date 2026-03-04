extends Node2D

@onready var death_sfx = $AudioStreamPlayer2DDeath

func _ready():
	death_sfx.pitch_scale = randf_range(0.8,1.5)
	death_sfx.play()
	await death_sfx.finished
	queue_free()
