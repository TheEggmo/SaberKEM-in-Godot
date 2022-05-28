extends Node

func _on_Button_pressed():
	var pk = $VBoxContainer2/PublicKey.get_text().split("\n")
#	var public_key = PublicKey.new(pk[0], PolyUtils.numstring_to_poly(pk[1], str(Params.p).length()))
	var public_key = PublicKey.new(pk[0].to_int(), MatrixUtils.numstring_to_vector(pk[1], str(Params.p).length(), Params.l, Params.n))
	var message = $VBoxContainer2/HBoxContainer/Input.get_text()
#	var message_poly = null # TODO Zaimplementować konwertowanie tekstu na wielomian
	var message_poly = PolyUtils.numstring_to_poly(message, 1)
	var message_encrypted = SaberPKE.Encrypt(message_poly, public_key)[0]
	$VBoxContainer2/HBoxContainer/Output.set_text(PolyUtils.poly_to_numstring(message_encrypted,1))
