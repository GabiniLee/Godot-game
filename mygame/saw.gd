@tool
extends Area2D
## Spinning saw that patrols back and forth from its start position by `travel`.
@export var radius: float = 10.0:
	set(v): radius = v; queue_redraw()
@export var travel: Vector2 = Vector2(80, 0)
@export var period: float = 3.0

var origin: Vector2
var t := 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	origin = position
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = radius * 0.85
	cs.shape = c
	add_child(cs)
	body_entered.connect(func(b): if b.is_in_group("player"): b.die())

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	t += delta
	position = origin + travel * (0.5 - 0.5 * cos(TAU * t / period))
	rotation += delta * 10.0

func _draw() -> void:
	var pts := PackedVector2Array()
	var teeth := 10
	for i in teeth * 2:
		var r := radius if i % 2 == 0 else radius * 0.72
		pts.append(Vector2.RIGHT.rotated(TAU * i / (teeth * 2.0)) * r)
	draw_colored_polygon(pts, Color(0.72, 0.74, 0.78))
	draw_circle(Vector2.ZERO, radius * 0.35, Color(0.85, 0.12, 0.12))
	draw_circle(Vector2.ZERO, radius * 0.12, Color(0.2, 0.2, 0.2))
