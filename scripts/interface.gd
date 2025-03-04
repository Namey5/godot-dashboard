class_name Interface
extends Control


static var instance: Interface

@export var min_window_size := Vector2i(640, 480)
@export var progress_popup: ProgressPopup


func _ready() -> void:
	instance = self
	get_window().min_size = min_window_size
