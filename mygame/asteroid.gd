extends Area2D
## Spiked asteroid that drifts slowly in a random direction inside `bounds`.
const TEX := preload("res://asteroid_nobg.png")

var radius := 20.0
var vel := Vector2.ZERO
var spin := 0.0
var bounds := Rect2()
var wander_t := 0.0

func setup(r: float, b: Rect2) -> void:
	radius = r
	bounds = b
	vel = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(18.0, 45.0)
	spin = randf_range(-0.8, 0.8)

func _ready() -> void:
	var s := Sprite2D.new()
	s.texture = TEX
	s.scale = Vector2.ONE * (radius * 2.0 / TEX.get_width()) * 1.25
	add_child(s)
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = radius * 1.05
	cs.shape = c
	add_child(cs)
	body_entered.connect(func(b): if b.is_in_group("player"): b.die())
	wander_t = randf_range(1.0, 3.0)

func _process(delta: float) -> void:
	wander_t -= delta
	if wander_t <= 0.0:
		# gently change heading so movement looks random
		vel = vel.rotated(randf_range(-0.9, 0.9))
		vel = vel.normalized() * clamp(vel.length() + randf_range(-8, 8), 15.0, 50.0)
		wander_t = randf_range(1.5, 3.5)
	position += vel * delta
	rotation += spin * delta
	if position.x < bounds.position.x + radius and vel.x < 0: vel.x = -vel.x
	if position.x > bounds.end.x - radius and vel.x > 0: vel.x = -vel.x
	if position.y < bounds.position.y + radius and vel.y < 0: vel.y = -vel.y
	if position.y > bounds.end.y - radius and vel.y > 0: vel.y = -vel.y

func _draw() -> void:
	# spikes around the rock
	var n := 10
	for i in n:
		var a := TAU * i / n
		var d := Vector2.RIGHT.rotated(a)
		var side := d.orthogonal() * radius * 0.22
		var base := d * radius * 0.85
		draw_colored_polygon(PackedVector2Array([base + side, base - side, d * radius * 1.55]), Color(0.78, 0.8, 0.85))
		draw_colored_polygon(PackedVector2Array([d * radius * 1.3 + side * 0.4, d * radius * 1.3 - side * 0.4, d * radius * 1.55]), Color(0.9, 0.15, 0.15))
