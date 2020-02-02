extends Node


var timer_to_let_player_go_back = 2

func _process(delta):
	timer_to_let_player_go_back -= delta
	if timer_to_let_player_go_back < 0:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().change_scene("res://scenes/Menu.tscn")


func _on_ButtonBack_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn")
