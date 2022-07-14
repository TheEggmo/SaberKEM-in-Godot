extends Node

# Zamień string na tablicę wielomianów stopnia 255
# TODO: Fix/delete this
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

# TODO: Fix/delete this
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
	var output = string_utf8.get_string_from_utf8()	
	return output
	
#	var output := ""
#	for poly in input:
#		output += PolyUtils.poly_to_numstring(poly, 256) + "\n"
#	return String(output)
	

func run_encryption(input :String, key :PublicKey) -> String:
	# Uzupełnij wiadomość zerami z tyłu
	var pad_count = 256 - input.length() % 256
	var input_padded = input
	for i in pad_count:
		input_padded += "0"
	# Zamień input z postaci stringa na tablice wielomianów
	var message :Array
	for c in input_padded:
		message.append(c.to_int())
	var message_split = Utils.split_array(message, 256)
	var poly_array :Array
	for msg in message_split:
		poly_array.append(PolyUtils.Array_to_Polynomial(msg))
	
	# Zaszyfruj wielomiany
	var poly_array_encrypted :Array
	for poly in poly_array:
		var enc_output = SaberPKE.Encrypt(poly, key)
		poly_array_encrypted.append(enc_output[0]) # cm
		poly_array_encrypted.append_array(MatrixUtils.vector_to_array(enc_output[1])) # bp
	var temp_out = String(PolyUtils.Polynomial_to_Array(poly_array_encrypted[0]))
#	return PolynomialArray_to_String([poly_array_encrypted[0]])
	return temp_out

func _on_Button_pressed():
	var pk = $VBoxContainer/PublicKey.get_text().split("\n")
	var public_key = PublicKey.new(pk[0].to_int(), MatrixUtils.numstring_to_vector(pk[1], str(Params.p).length(), Params.l, Params.n))
	
	var message = $VBoxContainer/HBoxContainer/Input.get_text()
	var message_encrypted = run_encryption(message, public_key)
	$VBoxContainer/HBoxContainer/Output.set_text(message_encrypted)
