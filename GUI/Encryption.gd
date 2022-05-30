extends Node

func run_encryption(input :String, key :PublicKey) -> String:
	# Zamień tekst na postać tablicy znaków UTF-8
	var string_utf8 = input.to_utf8()
	# Zamień znaki UTF-8 na tablicę bitów
	var bits = Utils.PoolByteArray_to_BitArray(string_utf8)
	# Utwórz tablicę zawierającą tablice bitów o długościach 256, gotowych do przerobienia na wielomiany
	var bits_poly_ready = Utils.split_array(bits, 256)
	# Utwórz tablicę wielomianów, gotowych do enkrypcji
	var poly_array :Array
	for b in bits_poly_ready:
		poly_array.append(PolyUtils.BitArray_to_Polynomial(b))
	# Zaszyfruj wielomiany
	var poly_array_encrypted :Array
	for p in poly_array:
		poly_array_encrypted.append(SaberPKE.Encrypt(p, key))
	return ""

func _on_Button_pressed():
	var pk = $VBoxContainer/PublicKey.get_text().split("\n")
##	var public_key = PublicKey.new(pk[0], PolyUtils.numstring_to_poly(pk[1], str(Params.p).length()))
	var public_key = PublicKey.new(pk[0].to_int(), MatrixUtils.numstring_to_vector(pk[1], str(Params.p).length(), Params.l, Params.n))
	
	var message = $VBoxContainer/HBoxContainer/Input.get_text()
	var message_encrypted = run_encryption(message, public_key)
	$VBoxContainer/HBoxContainer/Output.set_text(message_encrypted)

#	var message = $VBoxContainer2/HBoxContainer/Input.get_text()
##	var message_poly = null # TODO Zaimplementować konwertowanie tekstu na wielomian
#	var message_poly = PolyUtils.numstring_to_poly(message, 1)
#	var message_encrypted = SaberPKE.Encrypt(message_poly, public_key)[0]
#	$VBoxContainer2/HBoxContainer/Output.set_text(PolyUtils.poly_to_numstring(message_encrypted,1))
