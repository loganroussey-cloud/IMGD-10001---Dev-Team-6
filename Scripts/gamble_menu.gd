extends Control

@onready var score_board: Node = get_node_or_null("../score_board")
@onready var sketch_man: CharacterBody2D = get_node_or_null("../sketch_man")

@onready var perks_layer: CanvasLayer = get_node_or_null("PerksLayer") as CanvasLayer
@onready var dimmer: ColorRect = get_node_or_null("PerksLayer/PerksRoot/Dimmer") as ColorRect
@onready var perk_list: VBoxContainer = get_node_or_null("PerksLayer/PerksRoot/PerksPanel/PerksVBox/Scroll/PerkList") as VBoxContainer

var perk_item_scene: PackedScene = preload("res://Scenes/perk_list_item.tscn")

var low_endroll := 1
var high_endroll := 10

var selected_perk: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sync_layer_visibility()
	if visible:
		refresh_perks()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_sync_layer_visibility()
		if visible and is_node_ready():
			refresh_perks()

func _process(_delta: float) -> void:
	if has_node("TextureButton") and sketch_man != null:
		position = sketch_man.position + Vector2(-550, -320)

func _sync_layer_visibility() -> void:
	if perks_layer:
		perks_layer.visible = visible
	if dimmer:
		dimmer.visible = visible

func _get_run_perks():
	return get_tree().root.get_node_or_null("RunPerks")

func refresh_perks() -> void:
	if perk_list == null:
		return

	for child in perk_list.get_children():
		child.queue_free()

	var run_perks = _get_run_perks()
	if run_perks == null:
		push_warning("RunPerks autoload not found at /root/RunPerks. Check Project Settings → AutoLoad.")
		return

	var counts: Dictionary = run_perks.get_perk_counts()
	var keys := counts.keys()
	keys.sort()

	for perk_id in keys:
		var perk_name := str(perk_id)
		var count := int(counts[perk_id])
		if count <= 0:
			continue

		var item = perk_item_scene.instantiate()
		item.setup(perk_name, count, perk_name == selected_perk)
		item.perk_selected.connect(_on_perk_selected)
		perk_list.add_child(item)

func _on_perk_selected(perk_id: String) -> void:
	selected_perk = perk_id
	for child in perk_list.get_children():
		if child.has_method("set_selected"):
			child.set_selected(child.perk_id == perk_id)

func get_selected_perk() -> String:
	return selected_perk
	
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var c := get_viewport().gui_get_hovered_control()
		if c:
			print("CLICK BLOCKED BY:", c.name, "  path:", c.get_path(), "  mouse_filter:", c.mouse_filter)
		else:
			print("NO HOVERED CONTROL (click should go to world)")

func _on_texture_button_pressed() -> void:
	if score_board == null:
		push_warning("score_board not found at ../score_board; slot machine rewards not applied.")
		return

	if "wrathkc" in score_board and int(score_board.get("wrathkc")) >= 2 and high_endroll >= 1:
		high_endroll -= 1

	var roll := randi_range(low_endroll, high_endroll)
	if roll == 1:
		if score_board.has_method("add_gold"):
			score_board.add_gold()
	else:
		if score_board.has_method("add_coal"):
			score_board.add_coal()
