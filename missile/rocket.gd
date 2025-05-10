extends CharacterBody2D

var direction: Vector2 = Vector2.RIGHT
@export var speed: float = 10

@export var explosion: PackedScene
@export var trail: PackedScene

func _ready() -> void:
	add_child(trail.instantiate())
	velocity =	direction * speed 
	look_at(position + direction)


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_collision(body: Node2D) -> void:
	print(body.name)
	if body is Player:
		print("Kill by direct hit")
		body.die()
	_explode()

func _explode() -> void:
	var expl: Area2D = explosion.instantiate()
	expl.global_position = global_position
	get_parent().add_child.call_deferred(expl)
	queue_free.call_deferred()
