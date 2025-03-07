class_name InstalledEngineView
extends EngineView


func initialise(engine_model: Variant) -> void:
	_model = engine_model
	version.text = _model.name
	path.text = _model.binary_path
