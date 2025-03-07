class_name Interface
extends Control


static var instance: Interface

@export var min_window_size := Vector2i(640, 480)
@export var progress_popup: ProgressPopup
@export var accept_dialog: AcceptDialog
@export var confirm_dialog: ConfirmationDialog


func _ready() -> void:
	instance = self
	get_window().min_size = min_window_size
	
	var label := accept_dialog.get_label()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label = confirm_dialog.get_label()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func show_error(title := "ERROR", message := "An error has occurred.", on_close := Callable()) -> void:
	accept_dialog.title = title
	accept_dialog.dialog_text = message

	if on_close.is_valid():
		accept_dialog.confirmed.connect(on_close, CONNECT_ONE_SHOT)
		accept_dialog.canceled.connect(on_close, CONNECT_ONE_SHOT)

	accept_dialog.show()


func show_confirmation(title := "CONFIRM", message := "Are you sure?", on_close := Callable()) -> void:
	if on_close.is_null():
		return

	confirm_dialog.title = title
	confirm_dialog.dialog_text = message
	confirm_dialog.confirmed.connect(on_close.bind(true), CONNECT_ONE_SHOT)
	confirm_dialog.canceled.connect(on_close.bind(false), CONNECT_ONE_SHOT)
	confirm_dialog.show()
