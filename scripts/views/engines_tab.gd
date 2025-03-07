class_name EnginesTab
extends ScrollContainer


@export var icon: Texture2D


func _ready() -> void:
	var tab_container := get_parent_control() as TabContainer
	if tab_container != null:
		tab_container.set_tab_icon(get_index(), icon)
