class_name EngineListView
extends PanelContainer


@export var header: CheckButton
@export var header_format := "Engines [{0}]"
@export var list_parent: VBoxContainer
@export var no_content_parent: Control
@export var next_page_button: Button

var _items: Array[EngineView] = []


func _ready() -> void:
	clear_items()


func clear_items() -> void:
	for item in _items:
		item.queue_free()
	_items.clear()

	header.text = header_format.format([0])
	no_content_parent.visible = true


func set_items(items: Array) -> void:
	clear_items()

	header.text = header_format.format([items.size()])
	no_content_parent.visible = items.is_empty()

	for item in items:
		var view := EngineView.create(item)
		list_parent.add_child(view)
