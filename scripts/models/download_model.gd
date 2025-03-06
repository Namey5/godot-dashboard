class_name DownloadModel
extends Node

signal page_fetched(success: bool, new_releases: Array)
signal install_completed(success: bool)

const RELEASE_LIST_URL := "https://api.github.com/repos/godotengine/godot/releases?per_page={page_size}&page={page_id}"
const TEMP_DIR := "user://temp"
const INSTALL_DIR := "user://engines"
const PLATFORM_ID_FORMAT := "{os}.{arch}"
const PLATFORM_ASSET_REGEXES := {
	# I'm on Linux.x86_64, so implement others as needed.
	"Linux.x86_64": "(.+x11\\.64\\.zip)|(.+linux\\.x86_64\\.zip)",
}

static var platform_id := PLATFORM_ID_FORMAT.format({"os": OS.get_name(), "arch": Engine.get_architecture_name()})
static var platform_asset_regex := RegEx.create_from_string(PLATFORM_ASSET_REGEXES[platform_id])

@export var results_per_page := 10

var _current_page := 1
var _release_list := []
var _list_request: HTTPRequest
var _install_request: HTTPRequest

var release_list: Array:
	get:
		return _release_list

var list_request_in_progress: bool:
	get:
		return _list_request != null

var install_request_in_progress: bool:
	get:
		return _install_request != null

var total_install_size: int:
	get:
		return _install_request.get_body_size() if install_request_in_progress else -1

var current_install_progress: int:
	get:
		return _install_request.get_downloaded_bytes() if install_request_in_progress else -1


func fetch_next_page() -> void:
	if list_request_in_progress:
		return

	var url := RELEASE_LIST_URL.format({ "page_size": results_per_page, "page_id": _current_page })

	_list_request = HTTPRequest.new()
	_list_request.request_completed.connect(_on_next_page_fetched)
	add_child(_list_request)
	
	print("Sending request: ", url)
	var result := _list_request.request(url)
	if result == OK:
		await _list_request.request_completed
	else:
		push_error("Failed to send request: ", result)
		page_fetched.emit(false, null)

	_list_request.queue_free()


func _on_next_page_fetched(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Request failed [result: ", result, ", code: ", response_code, "]")
		page_fetched.emit(false, null)
		return

	var body_json := body.get_string_from_utf8()
	var releases: Variant = JSON.parse_string(body_json)
	if releases == null or releases is not Array:
		push_error("Failed to parse json: ", body_json)
		page_fetched.emit(false, null)
		return

	print("Successfully fetched ", releases.size(), " releases.")
	_release_list.append_array(releases)
	page_fetched.emit(true, releases)
	_current_page += 1


func install_release(release: Variant) -> void:
	if install_request_in_progress:
		return

	var err: Error

	var desired_asset: Variant
	for asset in release.assets:
		if platform_asset_regex.search(asset.name) != null:
			desired_asset = asset

	if desired_asset == null:
		push_error("Failed to find supported asset.")
		install_completed.emit(false)
		return

	var url := desired_asset.browser_download_url as String
	
	err = DirAccess.make_dir_recursive_absolute(TEMP_DIR)
	assert(err == OK)
	var file_name := url.substr(url.rfind("/") + 1)
	if not file_name.ends_with(".zip"):
		push_error("Failed to find supported asset.")
		install_completed.emit(false)
		return

	_install_request = HTTPRequest.new()
	_install_request.request_completed.connect(_on_release_downloaded)
	_install_request.download_file = "%s/%s" % [TEMP_DIR, file_name]
	add_child(_install_request)
	
	print("Sending request: ", url)
	var result := _install_request.request(url)
	if result == OK:
		await _install_request.request_completed
	else:
		push_error("Failed to send request: ", result)
		install_completed.emit(false)

	_install_request.queue_free()


func _on_release_downloaded(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	_body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Request failed [result: ", result, ", code: ", response_code, "]")
		install_completed.emit(false)
		return

	var err: Error
	
	var dir_name := _install_request.download_file \
		.substr(_install_request.download_file.rfind("/") + 1) \
		.rstrip(".zip")
	assert(not dir_name.is_empty())
	var install_dir := "%s/%s" % [INSTALL_DIR, dir_name]
	err = DirAccess.make_dir_recursive_absolute(install_dir)
	assert(err == OK)

	var zip_path := _install_request.download_file
	var zip_reader := ZIPReader.new()
	err = zip_reader.open(zip_path)
	if err != OK:
		push_error("Failed to open zip '", zip_path, "': ", err)
		install_completed.emit(false)
		return

	var files := zip_reader.get_files()
	for file in files:
		var path := "%s/%s" % [install_dir, file]
		var output := FileAccess.open(path, FileAccess.WRITE)
		if output == null:
			push_error("Failed to write file '", path, "': ", FileAccess.get_open_error())
			install_completed.emit(false)
			return

		var bytes := zip_reader.read_file(file)
		output.store_buffer(bytes)
		output.close()
		FileAccess.set_unix_permissions(
			path,
			FileAccess.UNIX_READ_OWNER
				| FileAccess.UNIX_WRITE_OWNER
				| FileAccess.UNIX_EXECUTE_OWNER
		)

	zip_reader.close()

	DirAccess.remove_absolute(zip_path);

	print("Successfully installed release.")
	install_completed.emit(true)
