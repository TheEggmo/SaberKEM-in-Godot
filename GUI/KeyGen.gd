extends Node

func _on_Button_pressed():
	var seed_A = randi()
	var seed_s = randi()
	var keypair = SaberPKE.KeyGen(seed_A, seed_s)
	$HBoxContainer/PublicKey.set_text(keypair.public.to_string())
	$HBoxContainer/SecretKey.set_text(keypair.secret.to_string())
