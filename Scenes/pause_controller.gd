extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("pause"):
		get_parent().toggle_pause_menu()

	if event.is_action_pressed("inventory"):
		get_parent().toggle_inventory_menu()
