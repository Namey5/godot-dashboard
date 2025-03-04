class_name DownloadModel
extends Node

signal page_fetched(success: bool, new_releases: Array)
signal install_completed(success: bool)

const BASE_URL := "https://api.github.com/repos/godotengine/godot/releases?per_page={page_size}&page={page_id}"
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

	_list_request = HTTPRequest.new()
	_list_request.request_completed.connect(_on_next_page_fetched)
	add_child(_list_request)

	var url := BASE_URL.format({ "page_size": results_per_page, "page_id": _current_page })
	print("Sending request: ", url)

	var result := _list_request.request(url)
	if result == OK:
		await _list_request.request_completed
	else:
		push_error("Failed to send request: ", result)
		_on_next_page_fetched(
			HTTPRequest.RESULT_REQUEST_FAILED,
			403,
			PackedStringArray(),
			PackedByteArray()
		)

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

	_install_request = HTTPRequest.new()
	_install_request.request_completed.connect(_on_release_downloaded)
	_install_request.download_file = "user://tmp.zip"
	add_child(_install_request)

	var desired_asset: Variant
	for asset in release.assets:
		if platform_asset_regex.search(asset.name) != null:
			desired_asset = asset

	var url := desired_asset.browser_download_url as String
	print("Sending request: ", url)

	var result := _install_request.request(url)
	if result == OK:
		await _install_request.request_completed
	else:
		push_error("Failed to send request: ", result)
		_on_release_downloaded(
			HTTPRequest.RESULT_REQUEST_FAILED,
			403,
			PackedStringArray(),
			PackedByteArray()
		)

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

	DirAccess.make_dir_recursive_absolute("user://engines")

	var zip_reader := ZIPReader.new()
	zip_reader.open("user://tmp.zip");
	var files := zip_reader.get_files()
	for file in files:
		var bytes := zip_reader.read_file(file)
		var path := "user://engines/%s" % file
		var output := FileAccess.open(path, FileAccess.WRITE)
		if output != null:
			output.store_buffer(bytes)
			output.close()
			FileAccess.set_unix_permissions(path, FileAccess.UNIX_READ_OWNER | FileAccess.UNIX_WRITE_OWNER | FileAccess.UNIX_EXECUTE_OWNER)
		else:
			print("Failed to write file '", path, "': ", FileAccess.get_open_error())
	zip_reader.close()

	DirAccess.remove_absolute("user://tmp.zip");

	print("Successfully installed release.")
	install_completed.emit(true)
