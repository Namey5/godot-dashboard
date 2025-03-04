class_name ProgressPopup
extends PanelContainer


@export var label: Label
@export var progress_bar: ProgressBar

var _progress_source := Callable()
var _hide_on_complete := true


func _ready() -> void:
	hide_popup()


func _process(_delta: float) -> void:
	if visible and _progress_source.is_valid():
		var progress: Variant = _progress_source.call()
		var current_progress := progress.current as int
		var total_progress := progress.total as int

		if total_progress > 0:
			progress_bar.indeterminate = false
			progress_bar.max_value = total_progress
			progress_bar.value = current_progress

			if _hide_on_complete and current_progress >= total_progress:
				hide_popup()
		else:
			progress_bar.indeterminate = true


func show_popup(progress_source: Callable, hide_on_complete: bool = true) -> void:
	_progress_source = progress_source
	_hide_on_complete = hide_on_complete
	visible = true


func hide_popup() -> void:
	_progress_source = Callable()
	visible = false
