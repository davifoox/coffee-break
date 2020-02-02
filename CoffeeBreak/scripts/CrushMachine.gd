extends KinematicBody2D

export var can_move = false
export var spikes_in = true

export var crush_speed = 100.0
export var crush_timer = 3.0
export var spike_in_out_timer = 3.0

export var flipped = false

var start_movement = true
var inwards = true

onready var spikes_on = preload("res://sprites/pistao_on.png")
onready var spikes_off = preload("res://sprites/pistao_off.png")

onready var initial_x_position = position.x

func _ready():
	$TimerCrushersTogether.wait_time = crush_timer
	$TimerCrush.wait_time = crush_timer
	$TimerSpikesInOut.wait_time = spike_in_out_timer
	if !can_move:
		spikes_in_out()
	rotation_degrees = 0
	
	if flipped:
		$Sprite.flip_h = true
		$CollisionShape2D1.position.x = -74.001
		$CollisionShape2D2.position.x = 372.641
		$CollisionShape2D3.position.x = 319.124
		
		$Area2DSpikes.position.x = 419.651
		
	else:
		$Sprite.flip_h = false
		$CollisionShape2D1.position.x = 72.1
		$CollisionShape2D2.position.x = -375.565
		$CollisionShape2D3.position.x = -320.252
		
		$Area2DSpikes.position.x = -426.28


func spikes_in_out():
	if can_move:
		$Sprite.texture = spikes_on
		$Area2DSpikes/CollisionShape2D.disabled = false
	else:
		spikes_in = !spikes_in
		#print($TimerSpikesInOut.wait_time)
		$TimerSpikesInOut.start()
		
func _on_TimerSpikesInOut_timeout():
	if spikes_in:
		$Sprite.texture = spikes_off
		$Area2DSpikes/CollisionShape2D.disabled = true
	else:
		$Sprite.texture = spikes_on
		$Area2DSpikes/CollisionShape2D.disabled = false
	spikes_in_out()


func _physics_process(delta):
	if can_move:
		move()
		stop_when_moving_back()

func stop():
	can_move = false
	#if inwards:
	if start_movement:
		#inwards = false
		start_movement = false
		#print($TimerCrushersTogether.wait_time)
		$TimerCrushersTogether.start()
	else:		
		start_movement = true
		#print($TimerCrushersTogether.wait_time)
		$TimerCrush.start()
		#$TimerCrush.start()
	
#func start_moving():
#	$TimerSpikes.start()
#func _on_TimerSpikes_timeout():
#	$TimerSpikes.start()

func move():
	#if start_movement:
	if start_movement:
		#if inwards:
		if flipped:
			move_and_slide(Vector2(crush_speed,0))
		else:
			move_and_slide(Vector2(-crush_speed,0))
	else:
		if flipped:
			move_and_slide(Vector2(-crush_speed,0))
		else:
			move_and_slide(Vector2(crush_speed,0))
		
func stop_when_moving_back():
	if flipped:
		if position.x <= initial_x_position:
			#start_movement = true
			#inwards = true
			stop()
	else:
		if position.x >= initial_x_position:
			#start_movement = true
			#inwards = true
			stop()
	

func _on_Area2DSpikes_body_entered(body):
	if body.is_in_group("player"):
		body.die()


func _on_Area2DSpikes_area_entered(area):
	if area.is_in_group("spikes"):
		#start_movement = true
		stop()


func _on_TimerCrushersTogether_timeout():
	can_move = true
	#start_movement = true

func _on_TimerCrush_timeout():
	can_move = true
	#start_movement = true



