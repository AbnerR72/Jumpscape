extends "res://scripts/level_template.gd"

var jugador_cerca: bool = false

@onready var puerta: StaticBody2D = $Puerta

func _ready() -> void:
	super._ready() 
	
	# Conectamos las señales del detector invisible por código
	$DetectorAtaque.body_entered.connect(_on_detector_entered)
	$DetectorAtaque.body_exited.connect(_on_detector_exited)

func _on_detector_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_cerca = true

func _on_detector_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_cerca = false

func _process(_delta: float) -> void:
	# Si el jugador está en la zona y ataca, abrimos la puerta
	if jugador_cerca and Input.is_action_just_pressed("attack"):
		puerta.abrir()
		
		# Opcional: Para evitar que la abra y cierre si sigue atacando
		$DetectorAtaque.queue_free() # Borramos el detector una vez cumplida su función
