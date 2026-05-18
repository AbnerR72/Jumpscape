extends "res://scripts/level_template.gd"

var golpes_dados: int = 0
@onready var puerta = $Puerta 
@onready var palanca = $palanca

func _ready() -> void:
	# super._ready() llama a la función _ready() del script "padre" (el template)
	# Esto es vital para que tu texto de UI y el menú de pausa se configuren bien.
	super._ready() 
	
	# Conectamos la palanca a nuestra función contadora
	palanca.activada.connect(_on_palanca_activada)

func _on_palanca_activada():
	golpes_dados += 1
	print("Golpes: ", golpes_dados)
	
	# Actualizamos la pista en pantalla para que el jugador sepa que algo está pasando
	$CapaUI/HUD/TextoNivel.text = str(golpes_dados) + " / 5"
	
	# Si llega a 5, abrimos la puerta
	if golpes_dados >= 5:
		puerta.abrir()
		$CapaUI/HUD/TextoNivel.text = "¡Camino libre!"
