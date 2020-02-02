extends Node

onready var theme_song = preload("res://audio/music/musica.ogg")
onready var menu_song = preload("res://audio/music/menu credito.ogg")


func change_music(song):
	
	$MusicPlayer.stop()

	if song == "theme":
		$MusicPlayer.stream = theme_song
	elif song == "menu":
		$MusicPlayer.stream = menu_song
		
	$MusicPlayer.play()
