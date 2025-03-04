class_name DownloadController
extends Node


@export var model: DownloadModel
@export var view: EngineListView


func _ready() -> void:
	_on_next_page_button_pressed()


func _on_next_page_button_pressed() -> void:
	view.next_page_button.disabled = true
	model.fetch_next_page()


func _on_download_model_page_fetched(success: bool, new_releases: Array) -> void:
	view.next_page_button.disabled = false
	if success:
		view.add_items(new_releases)
	else:
		var popup := AcceptDialog.new()
		popup.dialog_text = "Failed to fetch new releases."
		popup.visible = true
		popup.visibility_changed.connect(
			func(visible: bool) -> void:
				if not visible:
					popup.queue_free()
		)
		add_child(popup)
		popup.move_to_center()


func _on_available_engines_item_main_button_pressed(item: EngineView) -> void:
	OS.shell_open(item.model.html_url)


func _on_available_engines_item_inner_button_pressed(item: EngineView) -> void:
	model.install_release(item.model)
	Interface.instance.progress_popup.show_popup(
		func() -> Variant:
			return {
				"current": model.current_install_progress,
				"total": model.total_install_size,
			},
		false
	)


func _on_download_model_install_completed(_success: bool) -> void:
	Interface.instance.progress_popup.hide_popup()
