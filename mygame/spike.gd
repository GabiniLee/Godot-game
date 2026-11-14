@tool
extends Area2D
## Row of spikes. Position = bottom-left of the row; spikes point up (rotate node to flip).
@export var width: float = 40.0:
	set(v): width = v; queue_redraw()
@export var spike_h: float = 10.0:
	set(v): spike_h = v; queue_redraw()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(width - 4.0, spike_h * 0.7)
	cs.shape = rect
	cs.position = Vector2(width / 2.0, -spike_h * 0.35)
	add_child(cs)
	body_entered.connect(func(b): if b.is_in_group("player"): b.die())

func _draw() -> void:
	var n: int = max(1, int(round(width / (spike_h * 0.9))))
	var w := width / n
	for i in n:
		var x := i * w
		draw_colored_polygon(PackedVector2Array([Vector2(x, 0), Vector2(x + w, 0), Vector2(x + w / 2.0, -spike_h)]), Color(0.75, 0.78, 0.82))
		draw_colored_polygon(PackedVector2Array([Vector2(x + w * 0.35, -spike_h * 0.6), Vector2(x + w * 0.65, -spike_h * 0.6), Vector2(x + w / 2.0, -spike_h)]), Color(0.85, 0.1, 0.1))
	draw_line(Vector2(0, 0), Vector2(width, 0), Color(0.3, 0.3, 0.35), 2.0)
