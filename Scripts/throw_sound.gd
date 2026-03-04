extends Node2D

@onready var throw_sfx = $AudioStreamPlayer2DThrow

func _ready():
	throw_sfx.pitch_scale = randf_range(0.8,1.5)
	throw_sfx.play()
	await throw_sfx.finished
	queue_free()
