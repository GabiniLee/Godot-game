extends Node2D
## Spawns spiked asteroids that drift around inside `area`, keeping clear of `safe_zones`.
const Asteroid := preload("res://asteroid.gd")
@export var count: int = 9
@export var area: Rect2 = Rect2(690, 30, 440, 540)
@export var min_radius: float = 14.0
@export var max_radius: float = 26.0
@export var safe_zones: Array[Rect2] = []

func _ready() -> void:
	randomize()
	for i in count:
		var a := Area2D.new()
		a.set_script(Asteroid)
		var r := randf_range(min_radius, max_radius)
		a.setup(r, area)
		var p := Vector2.ZERO
		for _try in 30:
			p = Vector2(randf_range(area.position.x + r, area.end.x - r), randf_range(area.position.y + r, area.end.y - r))
			var ok := true
			for z in safe_zones:
				if z.grow(r * 1.6).has_point(p): ok = false
			for c in get_children():
				if c.position.distance_to(p) < r * 3.5: ok = false
			if ok: break
		a.position = p
		add_child(a)
