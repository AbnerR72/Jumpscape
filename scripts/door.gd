extends StaticBody2D

# Referencia al nodo del audio
@onready var sonido = $AudioStreamPlayer2D

var esta_abierta: bool = false
var posicion_original: Vector2

func _ready():
	# Guardamos la posición inicial al arrancar el juego
	# Así siempre sabremos a dónde debe regresar al cerrarse
	posicion_original = position

func abrir():
	if esta_abierta: return 
	esta_abierta = true
	
	sonido.play()
	
	# Creamos un Tween
	var tween = create_tween()
	
	# Configuramos la animación:
	# 1. Qué nodo mover (self, o sea, la puerta)
	# 2. Qué propiedad cambiar ("position")
	# 3. A dónde moverla (Posición original menos 64 píxeles en Y para subir)
	# 4. Cuánto tiempo tarda (0.5 segundos)
	var nueva_posicion = posicion_original + Vector2(0, -64)
	tween.tween_property(self, "position", nueva_posicion, 0.5)
	
	print("La puerta se desliza hacia arriba.")

func cerrar():
	if not esta_abierta: return
	esta_abierta = false
	
	sonido.play()
	
	var tween = create_tween()
	# Hacemos que baje a su posición original en 0.5 segundos
	tween.tween_property(self, "position", posicion_original, 0.5)
	
	print("La puerta se cierra.")


# --- CÓDIGO TEMPORAL PARA PROBAR EL FUNCIONAMIENTO DE LA PUERTA ---
#func _input(event: InputEvent) -> void:
	 #Si presionamos Enter o Espacio (ui_accept)
	#if event.is_action_pressed("ui_accept"):
		#if esta_abierta:
			#cerrar()
		#else:
			#abrir()
