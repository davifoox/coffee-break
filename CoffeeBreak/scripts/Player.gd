extends KinematicBody2D

onready var jump_sound = $SFX/Jump
onready var hit_floor_sound = $SFX/HitFloor
onready var step_sound = $SFX/Step
onready var die_sound = $SFX/Die

onready var collision_shape = $CollisionShape2D
onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var animation_player_effects = $AnimationPlayerEffects

#onready var audio = $AudioStreamPlayer

var speed = 500
var acc = 50
var gravity = 2500
var velocity = Vector2()
var jump_force = 750
var floor_normal = Vector2(0, -1)
var current_anim = "idle"
var alive = true
var facing_right = true
var is_reloading = false
var is_shooting = false
export var current_dir = "right"

# WALL JUMP
var last_side_collision = ""

var wall_friction = 0.6 #Quato menor o valor maior a fricção
var just_wall_jumped_timer = 0.15
var just_wall_jumped_timer_left = 0

var has_just_touched_wall_timer = .25
var has_just_touched_wall_timer_left = 0

var area2d_left_colliding = false
var area2d_right_colliding = false

var wall_jump_dir = 1

var jumped = false

onready var air_timer = can_still_jump_time
var can_still_jump_time = 0.1
#----------------------------------------------------------

var jump_press_delay = 0.1 #Default = 0.1
var jump_press_delay_time_left = 0

var was_on_floor = false
var was_on_floor_delay = 0.1 #Default = 0.1 (Coyote Time)
var was_on_floor_delay_time_left = 0

var step_sound_time = 0.2
var step_sound_time_left = 0

var dead = false

func _ready():
	Engine.time_scale = 1
	flip_player(current_dir)

func _physics_process(delta):
	
	if dead:
		velocity.x = 0
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, floor_normal)
		return
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("shoot") and !is_shooting and !is_reloading:
		$SFX/NoAmmo.play()
	
	if is_shooting:
		velocity.y += (gravity * 0.001) * delta
		velocity.x = 0
		move_and_slide(velocity, floor_normal)
		return
	
	velocity.y += gravity * delta
	
	if Input.is_action_pressed("right"):
		if just_wall_jumped_timer_left <= 0:
			if velocity.x < speed:
				velocity.x = min(velocity.x + acc, speed)
			if velocity.x > speed:
				velocity.x = lerp(velocity.x, speed, 0.5)
			flip_player("right")
			facing_right = true
			if is_on_floor():
				animation("run")
				play_step_sound(delta)
	elif Input.is_action_pressed("left"):
		if just_wall_jumped_timer_left <= 0:
			if velocity.x > -speed:
				velocity.x = max(velocity.x - acc, -speed)
			if velocity.x < -speed:
				velocity.x = lerp(velocity.x, -speed, 0.5)
			flip_player("left")
			facing_right = false
			if is_on_floor():
				animation("run")
				play_step_sound(delta)
	else:
		if just_wall_jumped_timer_left <= 0:
			if !is_on_floor():
				if jumped:
					velocity.x = lerp(velocity.x , 0, 0.05)
				else:
					velocity.x = 0
			if is_on_floor():
				velocity.x = lerp(velocity.x , 0, 0.5)
				animation("idle")
		
	jump(delta)
	wall_jump(delta)
		
	velocity = move_and_slide(velocity, floor_normal)

	fall_check()
	
	
func flip_player(direction):
	
#	if direction == current_dir:
#		return
	
	if direction == "right":
		$Sprite.flip_h = true
		$Sprite.flip_h = true
	elif direction == "left":
		$Sprite.flip_h = false
		$Sprite.flip_h = false
		
	current_dir = direction
		
func animation(anim_name):
	
	if current_anim == anim_name:
		return
	
	match anim_name:
		"idle":
			animation_player.play("idle")
		"run":
			animation_player.play("run")
		"jump":
			animation_player.play("jump")
		"fall":
			animation_player.play("fall")
			
	current_anim = anim_name
	
func jump(delta):
	
	jump_press_delay_time_left -= delta
	was_on_floor_delay_time_left -= delta
	
	if !is_on_floor():
		if was_on_floor:
			was_on_floor_delay_time_left = was_on_floor_delay
			was_on_floor = false
		if velocity.y > 16:
			animation("fall")
		if Input.is_action_just_pressed("jump"):
			jump_press_delay_time_left = jump_press_delay
			if was_on_floor_delay_time_left > 0:
				was_on_floor_delay_time_left = 0
				
				animation("jump")
				play_sprite_effect("jump")
				play_sound("jump")
				
				velocity.y = -jump_force
			
	if is_on_floor():
		if !was_on_floor:
			#EFEITO DE ANIMAÇÃO AMASSANDO
			play_sound("hit_floor")
			play_sprite_effect("hit_floor")
		was_on_floor = true
		if Input.is_action_just_pressed("jump") or jump_press_delay_time_left > 0:
			
			animation("jump")
			play_sprite_effect("jump")
			play_sound("jump")
			
			velocity.y = -jump_force
			
	elif Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y *= 0.3
		animation("fall")

var hit_floor_once = false

func play_sound(sound_name):
	match sound_name:
		"jump":
			jump_sound.play()
		"hit_floor":
			if hit_floor_once:
				hit_floor_sound.play()
			hit_floor_once = true
		"step":
			if !step_sound.playing:
				step_sound.pitch_scale = rand_range(0.9, 1.1)
				step_sound.play()
		"die":
			die_sound.play()
		"wall_jump":
			$SFX/WallJump.play()
			
	
func play_step_sound(delta):
	step_sound_time_left -= delta
	
	if step_sound_time_left < 0:
		play_sound("step")
		step_sound_time_left = step_sound_time
	
func play_sprite_effect(effect_name):
	match effect_name:
		"jump":
			animation_player_effects.play("jump")
		"hit_floor":
			animation_player_effects.play("hit_floor")
	
func fall_check():
	if position.y > 1080 + 100:
		alive = false
		set_physics_process(false)
		play_sound("die")
		yield(die_sound, "finished")
		#Game.times_died += 1
		get_tree().reload_current_scene()

	
func lose():
	if !dead:
		set_physics_process(false)
	$TimerLose.start()
	yield($TimerLose, "timeout")
	
func die():
	if dead:
		return
	Engine.time_scale = 1
	get_tree().get_nodes_in_group("camera")[0].shake()
	$SFX/ShotInTheHead.play()
	$AnimationPlayer.play("die")
	dead = true
	$TimerLose.start()
	yield($TimerLose, "timeout")
	
func wall_jump(delta):
	
	var wall_jump_force_mult = 600
	
	if is_on_floor():
		jumped = false
	var wall_jump_force = Vector2((wall_jump_dir) * wall_jump_force_mult, -jump_force)
	just_wall_jumped_timer_left -= delta
	has_just_touched_wall_timer_left -= delta
	
	if area2d_left_colliding:
		if velocity.y > 0 and Input.is_action_pressed("left"):
			velocity.y *= wall_friction
		has_just_touched_wall_timer_left = has_just_touched_wall_timer
		wall_jump_dir = 1
		$Sprite.flip_h = true
		if last_side_collision != "left":
			last_side_collision = "left"
			jumped = false
	if area2d_right_colliding:
		if velocity.y > 0 and Input.is_action_pressed("right"):
			velocity.y *= wall_friction
		has_just_touched_wall_timer_left = has_just_touched_wall_timer
		wall_jump_dir = -1
		$Sprite.flip_h = false
		if last_side_collision != "right":
			last_side_collision = "right"
			jumped = false
		jumped = false
		
	wall_jump_force = Vector2((wall_jump_dir) * wall_jump_force_mult, -jump_force)
	
	if has_just_touched_wall_timer_left > 0 and !jumped:
		if !is_on_floor():
			pass
			#anim = 'wall'
		if Input.is_action_just_pressed("jump") and !$RayCast2DDown.is_colliding():
			play_sound('wall_jump')
			#vibrate_controller('jump')
			velocity = wall_jump_force
			jumped = true
			air_timer = 0
			has_just_touched_wall_timer_left = 0
			just_wall_jumped_timer_left = just_wall_jumped_timer

# WALL COLLISION DETECTION-------------
func _on_Area2DLeft_body_entered(body):
	if body.name != name and !body.is_in_group("enemy"):
		wall_jump_dir = 1
		area2d_left_colliding = true
func _on_Area2DRight_body_entered(body):
	if body.name != name and !body.is_in_group("enemy"):
		wall_jump_dir = -1
		area2d_right_colliding = true
func _on_Area2DLeft_body_exited(body):
	if body.name != name and !body.is_in_group("enemy"):
		area2d_left_colliding = false
func _on_Area2DRight_body_exited(body):
	if body.name != name and !body.is_in_group("enemy"):
		area2d_right_colliding = false
