tool
extends VBoxContainer


export var title := "Title" setget _set_title, _get_title
export var readonly := false setget _set_readonly, _get_readonly

func get_text() -> String:
	return $TextEdit.text

func set_text(text :String):
	$TextEdit.text = text

func _set_title(text :String):
	$Label.text = text
func _get_title():
	return $Label.text

func _set_readonly(val :bool):
	$TextEdit.readonly = val
func _get_readonly():
	return $TextEdit.readonly
