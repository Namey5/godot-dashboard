class_name DownloadController
extends Node


@export var model: DownloadModel
@export var view: EngineListView


func _ready() -> void:
	_on_next_page_button_pressed()


func _on_download_model_on_page_fetched(success: bool, new_releases: Array) -> void:
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


func _on_next_page_button_pressed() -> void:
	view.next_page_button.disabled = true
	model.fetch_next_page()
