class_name EngineListView
extends PanelContainer


@export var header: CheckButton
@export var header_format := "Engines [{0}]"
@export var list_parent: VBoxContainer
@export var no_content_parent: Control
@export var next_page_button: Button

var _item_views: Array[EngineView] = []


func _ready() -> void:
	clear_items()


func clear_items() -> void:
	for view in _item_views:
		view.queue_free()
	_item_views.clear()

	header.text = header_format.format([0])
	no_content_parent.visible = true


func add_items(items: Array) -> void:
	for item in items:
		var view := EngineView.create(item)
		list_parent.add_child(view)
		_item_views.append(view)

	header.text = header_format.format([_item_views.size()])
	no_content_parent.visible = _item_views.is_empty()


func set_items(items: Array) -> void:
	clear_items()
	add_items(items)
