extends Area2D

signal activada # Señal para avisar a la puerta

var jugador_cerca: bool = false
#var ya_activada: bool = false

func _ready() -> void:
	# Conectamos las señales para saber si el jugador entra o sale del rango
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_cerca = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false

func _process(_delta: float) -> void:
	if jugador_cerca and Input.is_action_just_pressed("attack"):
		activar_palanca()

func activar_palanca():
	# Reiniciamos la animación para que se vea el golpe cada vez
	$AnimatedSprite2D.stop() 
	$AnimatedSprite2D.play("activar") 
	
	activada.emit() # Emitimos la señal en cada golpe	
