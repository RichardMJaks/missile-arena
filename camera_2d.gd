extends Camera2D

@export var player_1: CharacterBody2D
@export var player_2: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.death_happened.connect(_zoom_to_dead)
	

func _zoom_to_dead(player: int) -> void:
	var pos: Vector2 = Vector2.ZERO
	if player == 0:
		pos = player_1.global_position
	if player == 1:
		pos = player_2.global_position	
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos, 0.1)\
	.set_ease(Tween.EASE_IN)

	tween.parallel().tween_property(self, "zoom", Vector2(13, 13), 0.1)\
	.set_trans(Tween.TRANS_LINEAR)


	tween.tween_callback(
	func():
		Engine.time_scale = 0.3
		var tween_1 = create_tween()
		print(self)
		tween_1.tween_property(self, "zoom", Vector2(15, 15), 3 * 0.3)\
		.set_trans(Tween.TRANS_LINEAR)

		tween_1.tween_callback(
		func():
			Engine.time_scale = 1
			var tween_2 = create_tween()
			tween_2.tween_property(self, "position", Vector2(105, 84), 0.2)\
			.set_ease(Tween.EASE_OUT)

			tween_2.parallel().tween_property(self, "zoom", Vector2(9, 9), 0.2)\
			.set_ease(Tween.EASE_OUT)
		
			tween_2.tween_callback(
			func():
				get_tree().create_timer(1).timeout.connect(get_tree().reload_current_scene)
			)
		)
	)


	
