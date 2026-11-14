extends CharacterBody2D
## Ball player. Movement is the original haven ball physics (instant run speed,
## move_toward stop, fixed jump impulse), scaled by `unit` so it fits any map size.
## Space level: set `jetpack = true` -> every jump press is a flappy-bird style thrust.

const SPEED = 900.0
const JUMP_VELOCITY = -900.0

@export var unit: float = 1.0            ## size/speed multiplier (1.0 = original big ball)
@export var jetpack: bool = false        ## space level only
@export var jet_thrust: float = -650.0   ## flap impulse (scaled by unit)
@export var jet_gravity: float = 0.6     ## gravity multiplier while on jetpack
@export var jet_max_fall: float = 900.0  ## terminal fall speed on jetpack (scaled)
@export var kill_y: float = 100000.0     ## falling below this respawns you
@export var cam_zoom: float = 0.0        ## 0 = keep camera's own zoom
@export var cam_limit: Rect2i = Rect2i() ## zero size = no camera limits

var spawn: Vector2
var radius: float = 40.0
var flame_t: float = 0.0
var dead_t: float = 0.0
@onready var sprite: Node2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	add_to_group("player")
	spawn = global_position
	var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs and cs.shape is CircleShape2D:
		radius = (cs.shape as CircleShape2D).radius * cs.scale.x
	var cam := get_node_or_null("Camera2D") as Camera2D
	if cam:
		if cam_zoom > 0.0:
			cam.zoom = Vector2(cam_zoom, cam_zoom)
		if cam_limit.size != Vector2i.ZERO:
			cam.limit_left = cam_limit.position.x
			cam.limit_top = cam_limit.position.y
			cam.limit_right = cam_limit.end.x
			cam.limit_bottom = cam_limit.end.y
		cam.position_smoothing_enabled = true
		cam.position_smoothing_speed = 8.0

func _physics_process(delta: float) -> void:
	if dead_t > 0.0:
		dead_t -= delta
		modulate.a = 0.4 if int(dead_t * 20) % 2 == 0 else 1.0
		if dead_t <= 0.0:
			modulate.a = 1.0
	var grav := get_gravity() * unit

	if jetpack:
		velocity += grav * jet_gravity * delta
		if Input.is_action_just_pressed("jump"):
			velocity.y = jet_thrust * unit
			flame_t = 0.18
		velocity.y = min(velocity.y, jet_max_fall * unit)
	else:
		if not is_on_floor():
			velocity += grav * delta
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY * unit

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * unit
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * unit)

	move_and_slide()

	# rolling ball look
	if sprite:
		sprite.rotation += velocity.x * delta / max(radius, 1.0)

	if flame_t > 0.0:
		flame_t -= delta
	if jetpack:
		queue_redraw()

	if global_position.y > kill_y or (jetpack and global_position.y < -200.0):
		die()
	elif _touching_hazard_tiles():
		die()

func _touching_hazard_tiles() -> bool:
	for layer in get_tree().get_nodes_in_group("hazard_tiles"):
		var tl := layer as TileMapLayer
		if tl == null:
			continue
		for i in 12:
			var p := global_position + Vector2.RIGHT.rotated(TAU * i / 12.0) * radius * 0.95
			if tl.get_cell_source_id(tl.local_to_map(tl.to_local(p))) != -1:
				return true
		if tl.get_cell_source_id(tl.local_to_map(tl.to_local(global_position))) != -1:
			return true
	return false

func die() -> void:
	if dead_t > 0.0:
		return  # brief invulnerability after respawn
	global_position = spawn
	velocity = Vector2.ZERO
	dead_t = 1.0
	var game := get_node_or_null("/root/Game")
	if game:
		game.on_player_died()

func _draw() -> void:
	if not jetpack:
		return
	# jetpack tank behind the ball (drawn under the sprite)
	var r := radius
	var tank := Rect2(Vector2(-r * 1.25, -r * 0.55), Vector2(r * 0.55, r * 1.1))
	draw_rect(tank, Color(0.55, 0.6, 0.7))
	draw_rect(tank, Color(0.2, 0.22, 0.28), false, max(1.0, r * 0.08))
	if flame_t > 0.0:
		var k := flame_t / 0.18
		var base := Vector2(-r * 0.975, r * 0.55)
		var pts := PackedVector2Array([base + Vector2(-r * 0.25, 0), base + Vector2(r * 0.25, 0), base + Vector2(0, r * (0.6 + 0.9 * k))])
		draw_colored_polygon(pts, Color(1.0, 0.55, 0.1))
		var inner := PackedVector2Array([base + Vector2(-r * 0.12, 0), base + Vector2(r * 0.12, 0), base + Vector2(0, r * (0.3 + 0.5 * k))])
		draw_colored_polygon(inner, Color(1.0, 0.95, 0.5))
