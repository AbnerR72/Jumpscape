extends Area2D

func _ready() -> void:
	# Conectamos la señal automáticamente por código
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Comprobamos si el objeto que nos tocó pertenece al grupo "player"
	if body.is_in_group("player"):
		# Comprobamos si ese jugador tiene la función de morir programada
		if body.has_method("morir"):
			body.morir() # Le ordenamos al jugador que ejecute su muerte
