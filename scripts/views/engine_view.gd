class_name EngineView
extends PanelContainer


const SCENE_ASSET := preload("res://scenes/engine.tscn")

@export var main_button: Button
@export var icon: TextureRect
@export var version: Label
@export var path: Label
@export var delete_button: Button

var _model: Variant


static func create(model: Variant) -> EngineView:
	var view := SCENE_ASSET.instantiate()
	view._model = model
	view.version.text = "Godot %s" % model.tag_name
	view.path.text = model.url
	return view
