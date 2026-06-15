extends CharacterBody2D

@export var speed = 300
@export var jump = -400

@export var modo_impulso_mouse: bool = false
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
	# --- NUEVO: MANEJO DE SALTO / PENALIZACIÓN ---
	if Input.is_action_just_pressed("jump"):
		if modo_impulso_mouse:
			# Si el modo especial está activo y presiona "W" o espacio, muere con Death2
			morir("death2")
			return
		elif puede_saltar and is_on_floor() and not is_crouching and not is_getting_up:
			# Salto normal para los niveles del 1 al 6
			velocity.y = jump * direccion_gravedad
			# Maneja el salto normal
			if puede_saltar and Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching and not is_getting_up:
				velocity.y = jump * direccion_gravedad
				$SonidoSalto.play() # <--- AÑADE ESTA LÍNEA
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
		
func morir(animacion_muerte: String = "death"):
	if esta_muerto: return # Evita que muera dos veces si toca dos pinchos a la vez
	
	esta_muerto = true
	velocity = Vector2.ZERO # Lo frenamos en seco por si venía corriendo
	# NUEVO: Le avisa a todos los enemigos del mapa que regresen a sus posiciones
	get_tree().call_group("enemigos", "reiniciar_posicion")
	
	# NUEVO: Si muere invertido, restauramos la gravedad normal para el respawn
	direccion_gravedad = 1
	up_direction = Vector2.UP
	animated_sprite_2d.flip_v = false
	

	$AnimatedSprite2D.play(animacion_muerte) 
	# Le decimos al código que pause esta función hasta que la animación termine
	await $AnimatedSprite2D.animation_finished
	# Lo teletransportamos al inicio
	global_position = posicion_inicial
	# Lo "revivimos"
	esta_muerto = false
	# Reproducimos su animación de estar quieto para que no se quede trabado en la de muerte
	$AnimatedSprite2D.play("idle")
	get_tree().reload_current_scene()
# Esta función se ejecuta automáticamente si haces click sobre el CollisionShape del personaje
func _input(event: InputEvent) -> void:
	# Al usar _input, Godot escucha el clic en TODA la pantalla
	if modo_impulso_mouse and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Aplicamos el impulso vertical directo
			velocity.y = -450
			
			# (Opcional) ¡Agrega tu sonido de salto aquí para darle más impacto!
			if has_node("SonidoSalto"):
				$SonidoSalto.play()
