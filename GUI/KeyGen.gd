extends VBoxContainer
tool

func _ready():
	$IOContainer/InputContainer/Label.text = "Klucz Publiczny"
	$IOContainer/OutputContainer/Label.text = "Klucz Prywatny"
	
	$IOContainer/InputContainer/TextEdit.readonly = true
	$IOContainer/OutputContainer/TextEdit.readonly = true
