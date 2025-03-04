class_name EngineView
extends PanelContainer


@export var main_button: Button
@export var icon: TextureRect
@export var version: Label
@export var path: Label
@export var inner_button: Button

var _model: Variant

var model: Variant:
	get:
		return _model


func initialise(engine_model: Variant) -> void:
	_model = engine_model
	version.text = "Godot %s" % engine_model.tag_name
	path.text = engine_model.html_url
