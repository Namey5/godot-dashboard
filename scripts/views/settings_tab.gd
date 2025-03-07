class_name SettingsTab
extends ScrollContainer


@export var icon: Texture2D
@export var install_path: PathSelector
@export var temp_path: PathSelector
@export var reset_button: Button
@export var save_button: Button


func _ready() -> void:
	var tab_container := get_parent_control() as TabContainer
	if tab_container != null:
		tab_container.set_tab_icon(get_index(), icon)
	
	Config.load_config()
	reset()


func restore_defaults() -> void:
	Config.reset_config()
	reset()


func reset() -> void:
	install_path.path = Config.install_dir
	temp_path.path = Config.temp_dir


func save() -> void:
	if install_path.path.is_empty() or ( \
			not DirAccess.dir_exists_absolute(temp_path.path) \
			and DirAccess.make_dir_recursive_absolute(temp_path.path) != OK):
		install_path.path = Config.install_dir
	else:
		Config.install_dir = install_path.path

	if temp_path.path.is_empty() or ( \
			not DirAccess.dir_exists_absolute(temp_path.path) \
			and DirAccess.make_dir_recursive_absolute(temp_path.path) != OK):
		temp_path.path = Config.temp_dir
	else:
		Config.temp_dir = temp_path.path

	var err := Config.save_config()
	if err != OK:
		push_error("Failed to save config: ", err)
		Interface.instance.show_error()
