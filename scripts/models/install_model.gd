class_name InstallModel
extends Node


const PLATFORM_ID_FORMAT := "{os}.{arch}"
const PLATFORM_BINARY_REGEXES := {
	# I'm on Linux.x86_64, so implement others as needed.
	"Linux.x86_64": "(.+x11\\.64)|(.+linux\\.x86_64)",
}

static var platform_id := PLATFORM_ID_FORMAT.format({"os": OS.get_name(), "arch": Engine.get_architecture_name()})
static var platform_binary_regex := RegEx.create_from_string(PLATFORM_BINARY_REGEXES[platform_id])

var _installed_engines := []

var installed_engines: Array:
	get:
		return _installed_engines


func refresh() -> void:
	_installed_engines.clear()

	for install in DirAccess.get_directories_at(Config.install_dir):
		var full_path := "%s/%s" % [Config.install_dir, install]

		var binary_file := ""
		for file in DirAccess.get_files_at(full_path):
			if platform_binary_regex.search(file) != null:
				binary_file = file
				break
		if binary_file.is_empty():
			continue

		_installed_engines.append({
			"name": install.replace("_", " "),
			"path": full_path,
			"binary_path": "%s/%s" % [full_path, binary_file]
		})

	_installed_engines.sort_custom(
		func(a: Variant, b: Variant) -> bool:
			return a.name > b.name
	)
