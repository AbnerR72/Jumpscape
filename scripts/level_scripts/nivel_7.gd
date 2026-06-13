extends "res://scripts/level_template.gd"

func _ready() -> void:
	# Esto ejecuta el código del HUD de level_template.gd antes de continuar
	super._ready()
	if player:
		player.speed = 200

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_salida_body_entered(body: Node2D) -> void:
	# 1. Verificamos que sea el personaje quien tocó la salida
	if body.is_in_group("jugador"):
		
		# 2. Usamos la variable que acabas de configurar en el Inspector
		# NOTA: Cambia 'siguiente_nivel' por el nombre exacto de la variable 
		# exportada tal y como está escrita en tu archivo level_template.gd
		if siguiente_nivel != null:
			get_tree().change_scene_to_file(siguiente_nivel)
		else:
			print("¡Error! No se ha asignado un Siguiente Nivel en el Inspector del Nivel 7")
