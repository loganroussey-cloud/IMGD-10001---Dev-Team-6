extends Control

@onready var score_board = get_node_or_null("../score_board")
@onready var sketch_man = get_node_or_null("../sketch_man")
@onready var slot_button: TextureButton = get_node_or_null("TextureButton") as TextureButton

# Perks UI (right-side list)
@onready var perks_layer: CanvasLayer = get_node_or_null("PerksLayer") as CanvasLayer
@onready var perk_list: VBoxContainer = get_node_or_null("PerksLayer/PerksRoot/PerksPanel/PerksVBox/Scroll/PerkList") as VBoxContainer

# Toast UI (may or may not exist in the scene depending on patch state)
@onready var toast_layer: CanvasLayer = get_node_or_null("PerksLayer/ToastLayer") as CanvasLayer
@onready var result_toast: Label = get_node_or_null("PerksLayer/ToastLayer/ResultToast") as Label

var perk_item_scene: PackedScene = preload("res://Scenes/perk_list_item.tscn")

# Slot machine odds tuning (matches your original)
var low_endroll := 1
var high_endroll := 10

# Selected perk to gamble (must be selected to spin)
var selected_perk: String = ""

var _toast_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Ensure screen UI follows this menu's visibility (prevents perks list being always on screen)
	_sync_ui_visibility()

	# Ensure slot button works while paused
	if slot_button:
		slot_button.process_mode = Node.PROCESS_MODE_ALWAYS
		if not slot_button.pressed.is_connected(_on_texture_button_pressed):
			slot_button.pressed.connect(_on_texture_button_pressed)

	_ensure_toast_exists()
	_refresh_perks()
	_update_slot_enabled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_sync_ui_visibility()
		if visible and is_node_ready():
			_ensure_toast_exists()
			_refresh_perks()
			_update_slot_enabled()

func _process(_delta: float) -> void:
	# Keep your original behavior: gamble_menu follows the player in world space.
	# If you want screen-locked UI, remove this block.
	if sketch_man != null:
		position = sketch_man.position + Vector2(-550, -320)

func _sync_ui_visibility() -> void:
	# The perks list lives in a CanvasLayer, so it won't automatically hide when this Control hides.
	if perks_layer:
		perks_layer.visible = visible
	if toast_layer:
		toast_layer.visible = visible

func _ensure_toast_exists() -> void:
	# If the scene doesn't currently have the toast label, create it at runtime so win/lose messages always show.
	if perks_layer == null:
		return

	if toast_layer == null:
		toast_layer = CanvasLayer.new()
		toast_layer.name = "ToastLayer"
		perks_layer.add_child(toast_layer)
		toast_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		toast_layer.layer = (perks_layer.layer + 1) if perks_layer else 1
		toast_layer.visible = visible

	if result_toast == null:
		result_toast = Label.new()
		result_toast.name = "ResultToast"
		toast_layer.add_child(result_toast)
		result_toast.process_mode = Node.PROCESS_MODE_ALWAYS
		result_toast.visible = false
		result_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		result_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		# Screen-ish placement (right side, near slot machine area) without editing your scene layout
		result_toast.anchor_left = 0.0
		result_toast.anchor_top = 0.0
		result_toast.anchor_right = 1.0
		result_toast.anchor_bottom = 0.0
		result_toast.offset_left = 0
		result_toast.offset_right = 0
		result_toast.offset_top = 24
		result_toast.offset_bottom = 90
		result_toast.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		result_toast.add_theme_constant_override("outline_size", 4)
		result_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))

func _get_run_perks():
	return get_tree().root.get_node_or_null("RunPerks")

func _refresh_perks() -> void:
	if perk_list == null:
		return

	for c in perk_list.get_children():
		c.queue_free()

	var run_perks = _get_run_perks()
	if run_perks == null:
		push_warning("RunPerks autoload not found at /root/RunPerks.")
		return

	var counts: Dictionary = run_perks.get_perk_counts()
	var keys := counts.keys()
	keys.sort()

	if selected_perk != "" and (not counts.has(selected_perk) or int(counts[selected_perk]) <= 0):
		selected_perk = ""

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

	_update_slot_enabled()

func _update_slot_enabled() -> void:
	if slot_button == null:
		return
	slot_button.disabled = (selected_perk == "")

func _show_result_toast(text: String) -> void:
	_ensure_toast_exists()
	if result_toast == null:
		return

	result_toast.text = text
	result_toast.visible = true

	result_toast.modulate.a = 0.0
	result_toast.scale = Vector2.ONE * 0.98

	if _toast_tween:
		_toast_tween.kill()

	_toast_tween = create_tween()
	_toast_tween.set_trans(Tween.TRANS_QUAD)
	_toast_tween.set_ease(Tween.EASE_OUT)

	_toast_tween.tween_property(result_toast, "modulate:a", 1.0, 0.12)
	_toast_tween.parallel().tween_property(result_toast, "scale", Vector2.ONE, 0.12)

	_toast_tween.tween_interval(0.85)

	_toast_tween.set_ease(Tween.EASE_IN)
	_toast_tween.tween_property(result_toast, "modulate:a", 0.0, 0.18)
	_toast_tween.finished.connect(func():
		if is_instance_valid(result_toast):
			result_toast.visible = false
	)

func _on_texture_button_pressed() -> void:
	# REQUIRE a perk bet
	if selected_perk == "":
		_show_result_toast("SELECT A PERK TO GAMBLE")
		_update_slot_enabled()
		return

	var run_perks = _get_run_perks()
	if run_perks == null:
		_show_result_toast("NO PERKS SYSTEM FOUND")
		return

	var counts: Dictionary = run_perks.get_perk_counts()
	var stacks := int(counts.get(selected_perk, 0))
	if stacks <= 0:
		_show_result_toast("NO STACKS OF " + selected_perk.to_upper())
		selected_perk = ""
		_refresh_perks()
		_update_slot_enabled()
		return

	if score_board != null and "wrathkc" in score_board and int(score_board.get("wrathkc")) >= 2 and high_endroll >= 1:
		high_endroll -= 1

	var roll := randi_range(low_endroll, high_endroll)

	if roll == 1:
		run_perks.add_perk_stacks(selected_perk, stacks)
		_show_result_toast("WIN! DOUBLED " + selected_perk.to_upper() + " (x" + str(stacks) + " → x" + str(stacks * 2) + ")")
	else:
		run_perks.remove_all_perks(selected_perk)
		_show_result_toast("LOSE! LOST ALL " + selected_perk.to_upper() + " (x" + str(stacks) + ")")
		selected_perk = ""

	_refresh_perks()
	_update_slot_enabled()
