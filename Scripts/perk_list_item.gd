extends PanelContainer

signal perk_selected(perk_id: String)

@onready var name_label: Label = $HBox/Name
@onready var count_label: Label = $HBox/Count
@onready var hover_overlay: ColorRect = $HoverOverlay
@onready var selected_outline: ColorRect = $SelectedOutline

var perk_id: String = ""
var perk_display_name: String = ""
var perk_count: int = 0

var _selected := false
var _hovered := false
var _tween: Tween

# If setup() runs before _ready(), we buffer the data here.
var _pending_setup := false
var _pending_id := ""
var _pending_count := 0
var _pending_selected := false

const DISPLAY_NAME_MAP := {
	"fire_rate": "Fire Rate",
	"crit_chance": "Crit Chance",
	"damage": "Damage",
	"speed": "Speed",
	"health": "Health",
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	hover_overlay.color.a = 0.0
	_apply_visuals(false)

	mouse_entered.connect(func():
		_hovered = true
		_apply_visuals(true)
	)
	mouse_exited.connect(func():
		_hovered = false
		_apply_visuals(true)
	)

	# If setup happened early, apply it now.
	if _pending_setup:
		_pending_setup = false
		_apply_setup(_pending_id, _pending_count, _pending_selected)

func setup(p_id, p_count: int, selected: bool = false) -> void:
	# If we're not ready yet, buffer and return safely.
	if not is_node_ready():
		_pending_setup = true
		_pending_id = str(p_id)
		_pending_count = p_count
		_pending_selected = selected
		return

	_apply_setup(str(p_id), p_count, selected)

func _apply_setup(id_str: String, p_count: int, selected: bool) -> void:
	perk_id = id_str
	perk_count = maxi(p_count, 0)
	_selected = selected
	_hovered = false

	perk_display_name = _to_display_name(perk_id)

	name_label.text = "+ " + perk_display_name.to_upper()
	count_label.text = "x" + str(perk_count)

	_apply_visuals(false)

func set_selected(v: bool) -> void:
	_selected = v
	_apply_visuals(true)

func _apply_visuals(animated: bool) -> void:
	var show_hover := _hovered or _selected

	selected_outline.visible = _selected

	var target_scale := Vector2(1.06, 1.06) if show_hover else Vector2.ONE
	var target_overlay := 0.32 if show_hover else 0.0
	var target_alpha := 1.0 if show_hover else 0.92

	if not animated:
		scale = target_scale
		modulate.a = target_alpha
		hover_overlay.color.a = target_overlay
		return

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_ELASTIC if show_hover else Tween.TRANS_QUAD)
	_tween.set_ease(Tween.EASE_OUT)

	_tween.parallel().tween_property(self, "scale", target_scale, 0.22 if show_hover else 0.14)
	_tween.parallel().tween_property(self, "modulate:a", target_alpha, 0.14)
	_tween.parallel().tween_property(hover_overlay, "color:a", target_overlay, 0.14)

func _to_display_name(id: String) -> String:
	if DISPLAY_NAME_MAP.has(id):
		return str(DISPLAY_NAME_MAP[id])

	var s := id.replace("_", " ").replace("-", " ")
	var parts := s.split(" ", false)
	for i in parts.size():
		var p := parts[i]
		parts[i] = p.left(1).to_upper() + p.substr(1).to_lower()
	return " ".join(parts)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		perk_selected.emit(perk_id)
