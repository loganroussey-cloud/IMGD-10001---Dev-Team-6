extends Node2D

@onready var slime_body_hurt: Sprite2D = $SlimeBody/SlimeBodyHurt

func play_walk():
	%AnimationPlayer.play("walk")


func play_hurt():
	%AnimationPlayer.play("hurt")
	slime_body_hurt.show()
	%AnimationPlayer.queue("walk")
