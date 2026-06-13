extends Control

func _ready() -> void:
	# Verificamos si la música principal NO está sonando y la encendemos.
	# (Cambia "MusicaNivel" por el nombre exacto de tu Autoload)
	if not MusicaFondo.playing:
		MusicaFondo.play()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level/nivel_0.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
