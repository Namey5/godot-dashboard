class_name ErrorPopup
extends PanelContainer

signal closed()

@export var title: Label
@export var message: Label
@export var button: Button


func _ready() -> void:
	hide_popup()


func show_popup(popup_title := "ERROR", popup_message := "An error occurred.", on_close := Callable()) -> void:
	title.text = popup_title
	message.text = popup_message
	if on_close.is_valid():
		closed.connect(on_close)
	visible = true


func hide_popup() -> void:
	visible = false
	closed.emit()
	for connection in closed.get_connections():
		closed.disconnect(connection.callable)
