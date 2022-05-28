extends VBoxContainer
tool

func _ready():
	$IOContainer/InputContainer/Label.text = "Klucz Publiczny"
	$IOContainer/OutputContainer/Label.text = "Klucz Prywatny"
	
	$IOContainer/InputContainer/TextEdit.readonly = true
	$IOContainer/OutputContainer/TextEdit.readonly = true


func _on_Button_pressed():
	var seed_A = randi()
	var seed_s = randi()
	var keypair = SaberPKE.KeyGen(seed_A, seed_s)
	$IOContainer/InputContainer/TextEdit.text = keypair.public.to_string()
	$IOContainer/OutputContainer/TextEdit.text = keypair.secret.to_string()
