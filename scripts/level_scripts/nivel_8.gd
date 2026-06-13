extends "res://scripts/level_template.gd"
@onready var puerta = $Puerta 
@onready var palanca = $palanca

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready() 
	
	# Conectamos la palanca a nuestra función contadora
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_abismo_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Comprobamos si ese jugador tiene la función de morir programada
		if body.has_method("morir"):
			body.morir()


func _on_palanca_activada() -> void:
	if puerta and puerta.has_method("abrir"):
		puerta.abrir()
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
