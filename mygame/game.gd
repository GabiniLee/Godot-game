extends Node
## Autoload "Game": level order, portal transitions, HUD.
const LEVELS := [
	["res://stoneage.tscn", "Stone Age"],
	["res://medieval.tscn", "Medieval"],
	["res://industrialrevolution.tscn", "Industrial Revolution"],
	["res://modernday.tscn", "Modern Day"],
	["res://spaceage.tscn", "Space Age  -  SPACE / W = jetpack"],
]
var deaths := 0
var hud: CanvasLayer
var label: Label
var big: Label
var fade: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hud = CanvasLayer.new()
	hud.layer = 50
	add_child(hud)
	label = Label.new()
	label.position = Vector2(16, 12)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	hud.add_child(label)
	fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(fade)
	big = Label.new()
	big.set_anchors_preset(Control.PRESET_FULL_RECT)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	big.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	big.add_theme_font_size_override("font_size", 56)
	big.add_theme_color_override("font_outline_color", Color.BLACK)
	big.add_theme_constant_override("outline_size", 12)
	hud.add_child(big)
	_update_hud.call_deferred()
	_show_title.call_deferred()

func current_index() -> int:
	var cs := get_tree().current_scene
	if cs == null: return 0
	for i in LEVELS.size():
		if LEVELS[i][0] == cs.scene_file_path: return i
	return 0

func _update_hud() -> void:
	var i := current_index()
	label.text = "Level %d/%d: %s     Deaths: %d" % [i + 1, LEVELS.size(), LEVELS[i][1], deaths]

func _show_title() -> void:
	var i := current_index()
	big.text = LEVELS[i][1].split("  -")[0]
	big.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.2)
	tw.tween_property(big, "modulate:a", 0.0, 0.6)

func on_player_died() -> void:
	deaths += 1
	_update_hud()

func next_level() -> void:
	var i := current_index() + 1
	var tw := create_tween()
	tw.tween_property(fade, "color:a", 1.0, 0.35)
	await tw.finished
	if i >= LEVELS.size():
		big.text = "YOU WIN!\nDeaths: %d" % deaths
		big.modulate.a = 1.0
		await get_tree().create_timer(3.0).timeout
		deaths = 0
		i = 0
	# skip a level whose files are missing (e.g. medieval art not copied in yet)
	var tries := 0
	while tries < LEVELS.size() and load(LEVELS[i][0]) == null:
		push_warning("Skipping level, could not load: " + LEVELS[i][0])
		i = (i + 1) % LEVELS.size()
		tries += 1
	get_tree().change_scene_to_file(LEVELS[i][0])
	await get_tree().process_frame
	await get_tree().process_frame
	_update_hud()
	_show_title()
	var tw2 := create_tween()
	tw2.tween_property(fade, "color:a", 0.0, 0.35)

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_R:
		get_tree().reload_current_scene()
