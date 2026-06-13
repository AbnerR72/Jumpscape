extends CharacterBody2D

@export var speed = 300
@export var jump = -400

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#Variables para el NIVEL 5
var puede_saltar: bool = true
var controla_gravedad: bool = false
var direccion_gravedad: int = 1

# Variables de estado
var is_attacking: bool = false
var is_crouching: bool = false
var is_getting_up: bool = false

#Variables para la muerte
var posicion_inicial: Vector2
var esta_muerto: bool = false

func _ready() -> void:
	posicion_inicial = global_position
	# Conectamos la señal que avisa cuando una animación termina
	
func _physics_process(delta: float) -> void:
	# --- NUEVO: BLOQUEO POR MUERTE ---
	# Si está muerto, detenemos la lectura de controles pero dejamos que caiga
	if esta_muerto:
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return # Este 'return' corta la función aquí para ignorar el resto del código
	# --------------------------------
	
	# --- NUEVO: MECÁNICA DE INVERSIÓN DE GRAVEDAD ---
	if controla_gravedad and Input.is_action_just_pressed("click"):
		direccion_gravedad *= -1 # Alterna entre 1 (normal) y -1 (invertida)
		
		# Le decimos al motor de físicas hacia dónde está el nuevo "arriba"
		# Si la gravedad es inversa, el techo actúa automáticamente como el suelo
		up_direction = Vector2.UP * direccion_gravedad 
		
		# Volteamos el sprite verticalmente si estamos en el techo
		animated_sprite_2d.flip_v = (direccion_gravedad == -1)
		
		# Reseteamos la velocidad vertical para que el cambio de dirección sea instantáneo
		velocity.y = 0
	
	# Agrega la gravedad.
	if not is_on_floor():
		velocity += get_gravity() * direccion_gravedad * delta
		is_crouching = false 
		is_getting_up = false
		
	# Devuelve la direccion del jugador --->  -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")

	# --- LÓGICA PARA AGACHARSE ---
	if is_on_floor() and not is_attacking:
		# Verifica que no se esté moviendo para poder agacharse, o que ya esté agachado
		if Input.is_action_pressed("sit") and (direction == 0 or is_crouching) and not is_getting_up:
			is_crouching = true
		# Cuando suelta la tecla 'S' estando agachado
		elif Input.is_action_just_released("sit") and is_crouching:
			is_crouching = false
			is_getting_up = true
			animated_sprite_2d.play("up") # Reproduce la animación de levantarse
			
	# Bloqueamos el movimiento si está agachado o levantándose
	if is_crouching or is_getting_up:
		direction = 0

	# Maneja el salto (Añadido 'puede_saltar' y ajustado para saltar en la dirección correcta)
	if puede_saltar and Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching and not is_getting_up:
		velocity.y = jump * direccion_gravedad
		$SonidoSalto.play() # Reproduce el sonido del salto
	
	# Invertir Sprite 
	if direction < 0:
		animated_sprite_2d.flip_h = true
	elif direction > 0:
		animated_sprite_2d.flip_h = false
		
	# Maneja el ataque (bloqueado si está agachado o levantándose)
	if Input.is_action_just_pressed("attack") and not is_crouching and not is_getting_up:
		is_attacking = true
		animated_sprite_2d.play("attack")
		$SonidoAtaque.play() # Reproduce el sonido de ataque
	
	# --- MANEJO DE ANIMACIONES ---
	# Solo reproduce animaciones normales si no está atacando y no se está levantando
	if not is_attacking and not is_getting_up:
		if is_crouching:

			if animated_sprite_2d.animation != "down":
				animated_sprite_2d.play("down")
		elif is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("run")
		else:
			if velocity.y < 0:
				animated_sprite_2d.play("jump")
			else:
				animated_sprite_2d.play("fall")
	
	# Agrega movimiento
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# Función que se dispara cuando una animación termina
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		is_attacking = false
	
	# Si terminó de levantarse, apaga la variable para que regrese a idle
	elif animated_sprite_2d.animation == "up":
		is_getting_up = false
		
func morir():
	if esta_muerto: return # Evita que muera dos veces si toca dos pinchos a la vez
	
	esta_muerto = true
	velocity = Vector2.ZERO # Lo frenamos en seco por si venía corriendo
	
	# NUEVO: Si muere invertido, restauramos la gravedad normal para el respawn
	direccion_gravedad = 1
	up_direction = Vector2.UP
	animated_sprite_2d.flip_v = false
	
	# IMPORTANTE: Cambia "AnimatedSprite2D" y "muerte" por los nombres exactos que tú uses
	$AnimatedSprite2D.play("death") 
	# Le decimos al código que pause esta función hasta que la animación termine
	await $AnimatedSprite2D.animation_finished 
	# Lo teletransportamos al inicio
	global_position = posicion_inicial
	# Lo "revivimos"
	esta_muerto = false
	# Reproducimos su animación de estar quieto para que no se quede trabado en la de muerte
	$AnimatedSprite2D.play("idle")
