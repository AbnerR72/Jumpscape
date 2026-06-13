extends "res://scripts/level_template.gd"

const PALABRA_OBJETIVO: String = "OPEN"
var palabra_actual: String = ""

@onready var puerta = $Puerta

func _ready() -> void:
	super._ready()
	
	# El truco maestro: conectamos la misma señal pero le inyectamos 
	# un string diferente a cada una usando .bind()
	$PalancaO.activada.connect(_on_palanca_activada.bind("O"))
	$PalancaP.activada.connect(_on_palanca_activada.bind("P"))
	$PalancaE.activada.connect(_on_palanca_activada.bind("E"))
	$PalancaN.activada.connect(_on_palanca_activada.bind("N"))
	$PalancaS.activada.connect(_on_palanca_activada.bind("S"))
	$PalancaA.activada.connect(_on_palanca_activada.bind("A"))
	
	# Dibujamos el estado inicial en la interfaz (ej: ----)
	#actualizar_interfaz_palabra()

# Esta función recibe la letra gracias al .bind() que hicimos arriba
func _on_palanca_activada(letra_recibida: String) -> void:
	# Si ya tiene 4 letras (un intento previo fallido que se está mostrando),
	# no dejamos que sume más hasta que se limpie
	if palabra_actual.length() >= 4:
		return
		
	# Sumamos la nueva letra a nuestra cadena
	palabra_actual += letra_recibida
	actualizar_interfaz_palabra()
	
	# Cuando el jugador completa las 4 letras, evaluamos el resultado
	if palabra_actual.length() == 4:
		if palabra_actual == PALABRA_OBJETIVO:
			puerta.abrir()
			print("¡Contraseña Correcta!")
		else:
			print("Contraseña Incorrecta. Reiniciando en 1 segundo...")
			# Le damos 1 segundo de retraso para que el jugador vea su error en pantalla
			await get_tree().create_timer(1.0).timeout
			palabra_actual = ""
			actualizar_interfaz_palabra()

func actualizar_interfaz_palabra() -> void:
	# Generamos el formato visual. Si lleva "OP", mostrará "OP__"
	var texto_visual = palabra_actual
	while texto_visual.length() < 4:
		texto_visual += "_"
		
	# Actualizamos el Label de tu plantilla UI en tiempo real
	# (Ajusta '$CapaUI/NombreNivel' al nombre exacto de tu nodo de texto)
	$CapaUI/HUD/TextoNivel.text = "" + texto_visual
