class_name DownloadModel
extends Node

signal on_page_fetched(success: bool, new_releases: Array)

const BASE_URL := "https://api.github.com/repos/godotengine/godot/releases?per_page={page_size}&page={page_id}"

@export var results_per_page := 10

var _request: HTTPRequest
var _current_page := 1
var _release_list := []

var request_in_progress: bool:
	get:
		return _request != null

var release_list: Array:
	get:
		return _release_list


func fetch_next_page() -> void:
	if request_in_progress:
		return

	_request = HTTPRequest.new()
	_request.request_completed.connect(_on_request_completed)
	add_child(_request)

	var url := BASE_URL.format({ "page_size": results_per_page, "page_id": _current_page })
	print("Sending request: ", url)

	var result := _request.request(url)
	if result == OK:
		await _request.request_completed
	else:
		push_error("Failed to send request: ", result)
		_on_request_completed(
			HTTPRequest.RESULT_REQUEST_FAILED,
			403,
			PackedStringArray(),
			PackedByteArray()
		)

	_request.queue_free()


func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Request failed [result: ", result, ", code: ", response_code, "]")
		on_page_fetched.emit(false, null)
		return

	var body_json := body.get_string_from_utf8()
	var releases: Variant = JSON.parse_string(body_json)
	if releases == null or releases is not Array:
		push_error("Failed to parse json: ", body_json)
		on_page_fetched.emit(false, null)
		return

	print("Successfully fetched ", releases.size(), " releases.")
	_release_list.append_array(releases)
	on_page_fetched.emit(true, releases)
	_current_page += 1
