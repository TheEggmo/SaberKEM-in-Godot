extends Node

# Zamień string na tablicę wielomianów stopnia 255
func String_to_PolynomialArray(input :String) -> Array:
	# Zamień tekst na postać tablicy znaków UTF-8
	var string_utf8 = input.to_utf8()
	# Zamień znaki UTF-8 na tablicę bitów
	var bits = Utils.PoolByteArray_to_BitArray(string_utf8)
	# Utwórz tablicę zawierającą tablice bitów o długościach 256, gotowych do przerobienia na wielomiany
	var bits_poly_ready = Utils.split_array(bits, 256)
	# Utwórz tablicę wielomianów, gotowych do enkrypcji
	var poly_array :Array
	for b in bits_poly_ready:
		poly_array.append(PolyUtils.Array_to_Polynomial(b))
	return poly_array

func PolynomialArray_to_String(input :Array) -> String:
	# Zamień tablicę wielomianów na tablicę tablic bitów
	var bits_poly_ready :Array
	for p in input:
		bits_poly_ready.append(PolyUtils.Polynomial_to_Array(p))
	# Połącz tablice bitów w jedną tablcę bitów
	var bits :Array
	for b in bits_poly_ready:
		bits.append_array(b)
	# Zamień tablicę bitów na tablicę znaków UTF-8
	var string_utf8 = Utils.BitArray_to_PoolByteArray(bits)
	# Zamień znaki UTF-8 na tekst
	return String(string_utf8)

func run_encryption(input :String, key :PublicKey) -> String:
	# Zaszyfruj wielomiany
	var poly_array_encrypted :Array
	for p in String_to_PolynomialArray(input):
		poly_array_encrypted.append(SaberPKE.Encrypt(p, key))
	return PolynomialArray_to_String(poly_array_encrypted) # TODO Ogarnąć łączenie wiadomości i tablicy bp w jedno jakoS

func _on_Button_pressed():
	var pk = $VBoxContainer/PublicKey.get_text().split("\n")
	var public_key = PublicKey.new(pk[0].to_int(), MatrixUtils.numstring_to_vector(pk[1], str(Params.p).length(), Params.l, Params.n))
	
	var message = $VBoxContainer/HBoxContainer/Input.get_text()
	var message_encrypted = run_encryption(message, public_key)
	$VBoxContainer/HBoxContainer/Output.set_text(message_encrypted)
