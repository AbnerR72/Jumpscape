extends Control

@export var velocidad_scroll: float = 20.0

@onready var musica_creditos = $MusicaCreditos

func _ready() -> void:
	# 1. Detenemos la música del Autoload normal
	if MusicaFondo.playing:
		MusicaFondo.stop()
		
	# 2. Preparamos el Fade-In
	musica_creditos.volume_db = -40.0 # Empezamos en silencio total
	musica_creditos.play() # Le damos "Play" a la canción estando en silencio
	
	# 3. Creamos el Tween (Interpolador matemático)
	var tween = create_tween()
	
	# Le decimos: "Anima el 'volume_db' de musica_creditos hasta llegar a 0.0, tardando 4.0 segundos"
	tween.tween_property(musica_creditos, "volume_db", 0.0, 4.0)

func _process(delta: float) -> void:
	# Movemos el texto hacia arriba constantemente
	$TextoCreditos.position.y -= velocidad_scroll * delta
	
	# Permitir al jugador saltar los créditos o salir presionando "Saltar" o "Escape"
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
		salir_de_creditos()

# Si el texto ya subió por completo y salió de la pantalla por arriba, salimos
func _on_texto_fuera_de_pantalla():
	pass # Opcional: puedes poner un nodo "VisibleOnScreenNotifier2D" para automatizar esto

func salir_de_creditos() -> void:
	print("Saliendo al menú principal...")

	get_tree().change_scene_to_file("res://scenes/menu.tscn") 
	
