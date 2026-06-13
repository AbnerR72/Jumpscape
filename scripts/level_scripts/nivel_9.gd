extends "res://scripts/level_template.gd"

@onready var puerta = $Puerta 
@onready var palanca = $palanca

@onready var mapa_ida = $TileMapLayer
@onready var mapa_regreso = $MapaRegreso

var posicion_inicial_puerta: float
var puerta_cerrandose: bool = false
@export var velocidad_cierre: float = 30.0 

func _ready() -> void:
	super._ready()
	
	# 1. FORZAR LA PUERTA A SU ESTADO DE REPOSO
	if puerta:
		posicion_inicial_puerta = puerta.global_position.y
		puerta_cerrandose = false
		
	if player:
		player.jump = -500
		
	# 2. FORZAR ENCENDIDO DEL MAPA DE IDA (EL COMBO COMPLETO)
	if mapa_ida:
		mapa_ida.show()
		mapa_ida.enabled = true 
		mapa_ida.collision_enabled = true # <-- Físicas de baldosas encendidas
		mapa_ida.set_process_mode(Node.PROCESS_MODE_INHERIT)
		
	# 3. FORZAR APAGADO DEL MAPA DE REGRESO (EL COMBO COMPLETO)
	if mapa_regreso:
		mapa_regreso.hide()
		mapa_regreso.enabled = false 
		mapa_regreso.collision_enabled = false # <-- Físicas de baldosas apagadas
		mapa_regreso.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	# 4. CONECTAR LA PALANCA
	if palanca and not palanca.activada.is_connected(_on_palanca_activada):
		palanca.activada.connect(_on_palanca_activada)

func _process(delta: float) -> void:
	if puerta_cerrandose and puerta.global_position.y < posicion_inicial_puerta:
		puerta.global_position.y += velocidad_cierre * delta
	elif puerta_cerrandose:
		puerta_cerrandose = false

func _on_abismo_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("jugador"):
		if body.has_method("morir"):
			body.morir()

func _on_palanca_activada() -> void:
	print("4. ¡BOOM! El jugador atacó la palanca.")
	
	puerta.global_position.y = posicion_inicial_puerta - 300 
	puerta_cerrandose = true
	
	# --- APAGAMOS EL MAPA DE IDA (COMBO COMPLETO) ---
	mapa_ida.hide()
	mapa_ida.enabled = false 
	mapa_ida.collision_enabled = false # <-- Ahora sí, el suelo viejo desaparece de las físicas
	mapa_ida.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	# --- ENCENDEMOS EL MAPA DE REGRESO (COMBO COMPLETO) ---
	mapa_regreso.show()
	mapa_regreso.enabled = true 
	mapa_regreso.collision_enabled = true # <-- El suelo nuevo se vuelve sólido
	mapa_regreso.set_process_mode(Node.PROCESS_MODE_INHERIT)
	print("5. ¡Cambio de mapas ejecutado!")

func _on_salida_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if siguiente_nivel != null:
			# Corrección del error rojo al salir del nivel
			get_tree().call_deferred("change_scene_to_file", siguiente_nivel)
		else:
			print("¡Error! No se ha asignado un Siguiente Nivel en el Inspector")
