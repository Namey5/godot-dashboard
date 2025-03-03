class_name DownloadModel
extends Node

signal on_page_fetched(success: bool)

const BASE_URL := "https://api.github.com/repos/godotengine/godot/releases?per_page={page_size}&page={page_id}"

@export var results_per_page := 10

var _request: HTTPRequest
var _current_page := 0
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

	var result := _request.request(BASE_URL.format({
		"page_size": results_per_page,
		"page_id": _current_page,
	}))

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
	var success := false
	if result == HTTPRequest.RESULT_SUCCESS:
		var body_string := body.get_string_from_utf8()
		var json: Variant = JSON.parse_string(body_string)
		if json != null or json is not Array:
			print("Successfully fetched ", json.size(), " releases.")
			_release_list.append_array(json)
			success = true
		else:
			push_error("Failed to parse json: ", body_string)
	else:
		push_error("Request failed [result: ", result, ", code: ", response_code, "]")

	on_page_fetched.emit(success)
	for callback in on_page_fetched.get_connections():
		on_page_fetched.disconnect(callback.callable)
