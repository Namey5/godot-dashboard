class_name DownloadController
extends Node


@export var model: DownloadModel
@export var view: EngineListView


func _ready() -> void:
	model.fetch_next_page()


func _on_download_model_on_page_fetched(success: bool) -> void:
	if success:
		view.set_items(model.release_list)
