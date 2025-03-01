extends Control


@export var min_window_size := Vector2i(640, 480)


func _ready() -> void:
	get_window().min_size = min_window_size
