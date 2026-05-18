extends "res://scripts/level_template.gd"


func _ready() -> void:
	super._ready()
	
	# Buscamos al jugador en el nivel (suponiendo que está en el grupo "player")
	var jugador = get_tree().get_first_node_in_group("player")
	
	if jugador:
		# ¡Sobrescribimos sus reglas normales!
		jugador.puede_saltar = false
		jugador.controla_gravedad = true
