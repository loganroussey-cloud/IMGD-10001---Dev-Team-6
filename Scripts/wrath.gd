extends Node2D

@onready var wrath_body_hurt: Sprite2D = $WrathBody/WrathBodyHurt

func play_walk():
	%AnimationPlayer.play("walk")


func play_hurt():
	%AnimationPlayer.play("hurt")
	wrath_body_hurt.show()
	%AnimationPlayer.queue("walk")
