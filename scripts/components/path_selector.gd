class_name PathSelector
extends HBoxContainer

var _user_dir := OS.get_user_data_dir()

@export var text_field: LineEdit
@export var browse_button: Button
@export var open_button: Button
@export var file_dialog: FileDialog

var path: String:
	get:
		return text_field.text
	set(value):
		text_field.text = value


func validate_path() -> void:
	if not path.is_empty():
		if path.begins_with(_user_dir):
			path = "user://%s" % path.trim_prefix(_user_dir).lstrip("/")


func browse_for_path() -> void:
	file_dialog.file_selected.connect(_on_browse)
	file_dialog.dir_selected.connect(_on_browse)
	file_dialog.canceled.connect(_on_browse.bind(""))
	file_dialog.current_dir = ProjectSettings.globalize_path(path)
	file_dialog.show()
	browse_button.disabled = true


func _on_browse(selected_path: String) -> void:
	browse_button.disabled = false
	file_dialog.file_selected.disconnect(_on_browse)
	file_dialog.dir_selected.disconnect(_on_browse)
	file_dialog.canceled.disconnect(_on_browse)

	if not selected_path.is_empty():
		if selected_path.begins_with(_user_dir):
			selected_path = "user://%s" % selected_path.trim_prefix(_user_dir).lstrip("/")
		path = selected_path


func open_in_file_manager() -> void:
	OS.shell_open(ProjectSettings.globalize_path(path))
