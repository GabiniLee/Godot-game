extends Area2D
## Put over the portal art at the end of a level. Touching it loads the next level.
@export var size: Vector2 = Vector2(80, 120)

var used := false

func _ready() -> void:
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	cs.shape = rect
	add_child(cs)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if used or not body.is_in_group("player"):
		return
	used = true
	get_node("/root/Game").call_deferred("next_level")
