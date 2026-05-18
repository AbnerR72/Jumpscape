extends AnimatableBody2D

@onready var sonido = $AudioStreamPlayer2D

var cayendo: bool = false
var velocidad_caida: float = 600.0 # Ajusta qué tan rápido cae

func _physics_process(delta: float) -> void:
	if cayendo:
		# move_and_collide mueve el objeto y se detiene automáticamente si choca con algo sólido (como el TileMap del suelo)
		var colision = move_and_collide(Vector2(0, velocidad_caida * delta))
		
		# Si choca contra el suelo, detenemos la caída
		if colision:
			cayendo = false
			print("Estalactita tocó el suelo")
			sonido.play()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Verificamos si el evento es un botón del ratón
	if event is InputEventMouseButton:
		# Verificamos si es el clic izquierdo y si acaba de ser presionado
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not cayendo: # Evita que se active múltiples veces
				cayendo = true
