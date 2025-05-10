extends Area2D

@export var force: float = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.explosion.emit()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body:Node2D) -> void:
	if not body.dead:
		body.die()

func _on_knockback_area_body_entered(body:Node2D) -> void:
	var vector_to_body = body.global_position - global_position
	var dir = (vector_to_body).normalized()
	body.velocity = dir * force
