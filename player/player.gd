extends CharacterBody2D

@export var player_suffix: String = "0"

@export var move_speed: float = 1
@export var acceleration_time: float = 0.1
@export var deceleration_time: float = 0.1

@export var fall_speed: float = 0
@export var fall_acceleration_time: float = 0.1
@export var jump_height: float = 1

@export var weapon_pivot: Node2D
@export var shoot_point: Marker2D
@export var missile: PackedScene
@export var shot_timer: Timer
@export var rocket_visual: Polygon2D
@export var sprite: MeshInstance2D
@export var death_particles: GPUParticles2D

@export var shoot_audio: AudioStreamPlayer
@export var jump_audio: AudioStreamPlayer
@export var missile_ready_audio: AudioStreamPlayer
@export var death_sound: AudioStreamPlayer
@export var anim_player: AnimationPlayer
@export var anim_tree: AnimationTree

var can_shoot: bool = true
var dead: bool = false
var can_control: bool = true

var mouse_controls: bool = true
func _ready() -> void:
	Global.death_happened.connect((func(): can_control = false).unbind(1))

func _physics_process(delta: float) -> void:
	anim_tree.set("parameters/Air/blend_position", velocity.y)
	if dead or not can_control:
		return
	
	if mouse_controls:
		weapon_pivot.look_at(get_global_mouse_position())
	else:
		var x = Input.get_joy_axis(int(player_suffix), JOY_AXIS_RIGHT_X)
		var y = Input.get_joy_axis(int(player_suffix), JOY_AXIS_RIGHT_Y)
		
		x = smoothstep(0.01, 1, absf(x)) * sign(x)
		y = smoothstep(0.01, 1, absf(y)) * sign(y)
		
		var look_dir = Vector2(x, y)
		
		if look_dir.length_squared() > 0:
			weapon_pivot.look_at(weapon_pivot.global_position + look_dir)
		
	if can_shoot and Input.is_action_just_pressed(&"a_shoot_" + player_suffix):
		_shoot()

	_handle_vertical_velocities(fall_speed, fall_acceleration_time, jump_height, delta)
	
	var dir: float = signf(Input.get_axis(&"m_left_" + player_suffix, &"m_right_" + player_suffix))
	
	if not dir:
		_decelerate(move_speed, deceleration_time, delta)
	if dir:
		_accelerate(dir, move_speed, acceleration_time, delta)

	move_and_slide()

#region Accelerations
func _accelerate(dir: float, speed: float, t_accel: float, delta: float) -> void:
	# Avoids division with 0
	if t_accel <= 0:
		velocity.x = speed * dir
		return
	
	velocity.x = move_toward(
		velocity.x, 
		speed * dir, 
		(speed) * (delta / t_accel)
	)

func _decelerate(speed: float, t_decel: float, delta: float) -> void:
	# Avoids division with 0
	if t_decel <= 0:
		velocity.x = 0
		return
	
	velocity.x = move_toward(
		velocity.x, 
		0, 
		speed * (delta / t_decel)
	)
#endregion

#region Vertical Movement

func _handle_vertical_velocities(
	gravity: float, g_accel: float, 
	jump_h: float, delta: float
) -> void:
	if not is_on_floor():
		_fall(gravity, g_accel, delta)
		return
	
	if Input.is_action_just_pressed(&"m_jump_" + player_suffix):
		_jump(jump_h, gravity, g_accel)
	
func _fall(g: float, accel: float, delta: float) -> void:
	velocity.y = move_toward(
		velocity.y, g, 
		g * (delta / accel)
	)

# Can also use custom logic later on
func _jump(height: float, gravity: float, gravity_accel) -> void:
	var force: float = get_jump_force(height, gravity, gravity_accel)
	velocity.y -= force
	jump_audio.play()

func get_jump_force(h: float, g: float, g_accel: float) -> float:
	return sqrt(2*(g/g_accel)*h)

#endregion

func _shoot() -> void:
	var rocket: CharacterBody2D = missile.instantiate()
	rocket.direction = Vector2.from_angle(weapon_pivot.rotation)
	rocket.global_position = shoot_point.global_position
	rocket.look_at(rocket.position + rocket.direction)
	get_parent().add_child(rocket)
	shot_timer.start()
	can_shoot = false
	rocket_visual.visible = false
	shoot_audio.play()


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_controls = true
	if event is InputEventJoypadMotion:
		mouse_controls = false


func _on_rocket_timer_timeout() -> void:
	can_shoot = true
	rocket_visual.position.x = 0.6
	rocket_visual.visible = true
	var tween = rocket_visual.create_tween()
	tween.tween_property(rocket_visual, "position:x", 1.15, 0.2)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_ease(Tween.EASE_OUT)
	missile_ready_audio.play()
	
func die() -> void:
	Global.death(int(player_suffix))
	death_particles.emitting = true
	dead = true
	sprite.visible = false
	death_sound.play()
