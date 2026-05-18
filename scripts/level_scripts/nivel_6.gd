extends "res://scripts/level_template.gd"

@onready var puerta = $Puerta 
var raton_encima: bool = false # Esta bandera sabrá si estamos apuntando a la puerta

func _ready() -> void:
	super._ready() 
	

func _on_mouse_entered() -> void:
	raton_encima = true

func _on_mouse_exited() -> void:
	raton_encima = false

func _process(_delta: float) -> void:
	# Si el cursor está sobre la puerta Y presionas el clic izquierdo
	if raton_encima and Input.is_action_just_pressed("click"):
		puerta.abrir()
		
		raton_encima = false # Apagamos la bandera por seguridad
		


func _on_button_pressed() -> void:
	puerta.abrir()
