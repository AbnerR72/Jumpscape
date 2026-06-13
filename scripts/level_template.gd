extends Node2D

# Referencia al jugador
@onready var player: CharacterBody2D = $personaje

# Referencias a la UI
@onready var hud: Control = $CapaUI/HUD
@onready var menu_pausa: Control = $CapaUI/MenuPausa

# Referencias a las 4 capas 
@onready var fondo: Parallax2D = $FondoRocas/Parallax2D       # La más lejana
@onready var rocaUno: Parallax2D = $FondoRocas/Parallax2D2
@onready var rocaDos: Parallax2D = $FondoRocas/Parallax2D3
@onready var rocaTres: Parallax2D = $FondoRocas/Parallax2D4 # La más cercana a la habitación

# Variables que cada nivel heredado podrá modificar
@export var nombre_nivel: String = "Nivel Desconocido"
@export var siguiente_nivel: String = "" # Ruta del siguiente nivel (ej: "res://niveles/nivel_02.tscn")
@export_multiline var texto_pista: String = "Pista no disponible." #Variable para las pistas


func _ready() -> void:
	# Actualizamos el texto en pantalla
	$CapaUI/HUD/TextoNivel.text = nombre_nivel
	
	# Nos aseguramos de que el menú de pausa esté oculto al iniciar
	menu_pausa.hide()
	
	# Asignamos el texto de la pista al Label
	$CapaUI/VentanaPista/TextoPista.text = texto_pista
	
	# Conectamos el botón de la pista (si no lo haces desde el editor visual)
	$CapaUI/BotonPista.pressed.connect(_on_boton_pista_pressed)

func _process(delta: float) -> void:
	# Lógica global: Reiniciar nivel con la tecla R (debes configurar "reiniciar" en el Input Map)
	if Input.is_action_just_pressed("reiniciar"):
		reiniciar_nivel()
		
		
	if player:
		# Obtenemos la posición base del jugador
		var pos_jugador = player.global_position
		
		# Aplicamos el movimiento a cada capa con diferente intensidad
		fondo.scroll_offset = pos_jugador * -0.01     # Se mueve poquísimo
		rocaUno.scroll_offset = pos_jugador * -0.03  # Se mueve un poco más
		rocaDos.scroll_offset = pos_jugador * -0.06    # Se mueve a velocidad media
		rocaTres.scroll_offset = pos_jugador * -0.1   # Se mueve rápido

# --- FUNCIONES DE CONTROL DE FLUJO ---

func reiniciar_nivel() -> void:
	print("Reiniciando: ", nombre_nivel)
	get_tree().reload_current_scene()

func nivel_completado() -> void:
	print("¡Nivel superado!")
	# Aquí puedes añadir animaciones de victoria antes de cambiar de escena
	
	if siguiente_nivel != "":
		get_tree().change_scene_to_file(siguiente_nivel)
	else:
		print("Juego Terminado o falta configurar la ruta del siguiente nivel")

func game_over() -> void:
	# Esta función la llamarán los pinchos o trampas cuando toquen al jugador
	print("El jugador ha muerto")

	call_deferred("reiniciar_nivel")
	


func _on_salida_body_entered(body: Node2D) -> void:
<<<<<<< HEAD
		if body.is_in_group("player"):
			call_deferred("nivel_completado")

func _on_boton_pista_pressed() -> void:
	var ventana = $CapaUI/VentanaPista
	var timer = $CapaUI/VentanaPista/Timer
	
	if not ventana.visible:
		# Si la ventana estaba oculta, la mostramos y arrancamos el reloj de 7 segundos
		ventana.visible = true
		timer.start()
	else:
		# Si el jugador decide cerrarla manualmente antes de los 7 segundos,
		# la ocultamos y detenemos el reloj para evitar bugs.
		ventana.visible = false
		timer.stop()

func _on_timer_timeout() -> void:
	var ventana = $CapaUI/VentanaPista
	ventana.visible = false
=======
	# Si está en el grupo viejo O en el grupo nuevo, pasa de nivel
	if body.is_in_group("player") or body.is_in_group("jugador"):
		call_deferred("nivel_completado")
>>>>>>> 6cd49c6 (hasta nivel 9)
