class_name InstallController
extends Node


@export var model: InstallModel
@export var view: EngineListView


func _ready() -> void:
	refresh()


func refresh() -> void:
	model.refresh()
	view.set_items(model.installed_engines)


func _on_installed_engines_item_main_button_pressed(item: EngineView) -> void:
	var binary := ProjectSettings.globalize_path(item.model.binary_path as String)
	if OS.create_process(binary, []) == -1:
		Interface.instance.error_popup.show_popup("ERROR", "Failed to launch %s" % item.model.name)


func _on_installed_engines_item_inner_button_pressed(item: EngineView) -> void:
	var install_path := ProjectSettings.globalize_path(item.model.path as String)
	var err := OS.move_to_trash(install_path)
	if err != OK:
		push_error("Failed to remove install '", install_path, "': ", err)
		Interface.instance.error_popup.show_popup()
		return

	refresh()
