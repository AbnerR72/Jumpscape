extends Area2D

# Parámetros ajustables
@export var velocidad_persecucion: float = 200.0
@export var distancia_salida_enemigo: float = 50.0 # Qué tan cerca aparecerá de la salida

# Referencias
@onready var sprite = $AnimatedSprite2D
@onready var jugador = get_tree().get_first_node_in_group("jugador") 

# Estados internos
var posicion_salida: Vector2
var velocidad_huida: float
var posicion_inicial_enemigo: Vector2 # Aquí declaramos la variable que faltaba

func _ready():
	velocidad_huida = velocidad_persecucion * 2
	
	# Lógica para posicionar al enemigo cerca de la salida
	var nodo_salida = get_parent().get_node_or_null("PuertaSalida")
	
	if nodo_salida:
		global_position = nodo_salida.global_position
		global_position += Vector2(-distancia_salida_enemigo, -distancia_salida_enemigo)
		
		# Guardamos la posición exacta donde apareció para poder reiniciarlo después
		posicion_inicial_enemigo = global_position 
	else:
		push_warning("EnemigoFantasma: No se encontró el nodo 'PuertaSalida' en el nivel actual.")
		queue_free()

func _process(delta):
	if not is_instance_valid(jugador): return

	var direccion = (jugador.global_position - global_position).normalized()
	
	if jugador.is_crouching:
		# HUIR
		global_position -= direccion * velocidad_huida * delta
	else:
		# PERSEGUIR
		global_position += direccion * velocidad_persecucion * delta

	# Girar el sprite
	if direccion.x > 0:
		sprite.flip_h = false 
	elif direccion.x < 0:
		sprite.flip_h = true 

# Función conectada desde el nodo para hacer daño
func _on_body_entered(body):
	if body.is_in_group("jugador") or body.is_in_group("player"):
		if body.has_method("morir"):
			body.morir("death2")

# Función que llama el jugador cuando muere para resetear al enemigo
func reiniciar_posicion():
	global_position = posicion_inicial_enemigo
