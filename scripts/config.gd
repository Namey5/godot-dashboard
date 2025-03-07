extends Node


const PATH := "user://config.cfg"
const SECTION := "Config"
const DEFAULT_INSTALL_DIR := "user://engines"
const DEFAULT_TEMP_DIR := "user://temp"

var install_dir: String:
	get:
		return _file.get_value(SECTION, "install_dir", DEFAULT_INSTALL_DIR)
	set(value):
		_file.set_value(SECTION, "install_dir", value)

var temp_dir: String:
	get:
		return _file.get_value(SECTION, "temp_dir", DEFAULT_TEMP_DIR)
	set(value):
		_file.set_value(SECTION, "temp_dir", value)

var _file := ConfigFile.new()


func _ready() -> void:
	load_config()


func load_config() -> Error:
	var err := _file.load(PATH)
	return err


func save_config() -> Error:
	return _file.save(PATH)


func reset_config():
	_file.clear()
