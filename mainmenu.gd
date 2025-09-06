extends Control
@onready var sein_btn: Button = %SeinButton

func _ready():
	sein_btn.pressed.connect(_go_to_sein)

func _go_to_sein() -> void:
	get_tree().change_scene_to_file("res://seinHaben.tscn")
