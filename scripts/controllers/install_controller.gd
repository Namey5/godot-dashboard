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
		Interface.instance.show_error("ERROR", "Failed to launch %s" % item.model.name)


func _on_installed_engines_item_inner_button_pressed(item: EngineView) -> void:
	Interface.instance.show_confirmation(
		"UNINSTALL",
		"Are you sure you wish to uninstall %s?" % item.model.name,
		func(confirmed: bool) -> void:
			if not confirmed:
				return
			
			var install_path := ProjectSettings.globalize_path(item.model.path as String)
			var err := remove_directory_recursive(install_path)
			if err != OK:
				push_error("Failed to remove install '", install_path, "': ", err)
				Interface.instance.show_error()
				return

			refresh()
	)


static func remove_directory_recursive(path: String) -> Error:
	var dir := DirAccess.open(path)
	if dir == null:
		return DirAccess.get_open_error()
	
	var err: Error
	for entry in dir.get_directories():
		err = remove_directory_recursive("%s/%s" % [path, entry])
		if err != OK:
			return err
	for file in dir.get_files():
		err = dir.remove(file)
		if err != OK:
			return err
	
	return DirAccess.remove_absolute(path)
