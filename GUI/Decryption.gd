extends VBoxContainer

func _on_Button_pressed():
	# Convert key string to polynomial vector
	var key_numstrings = $VBoxContainer/PrivateKey.get_text().split("\n")
	var key_poly_array :Array
	for string in key_numstrings:
		key_poly_array.append(PolyUtils.String_to_Polynomial(string))
	var s = MatrixUtils.array_to_vector(key_poly_array)
	
	# Convert input to coded message and bp vector
	var input = $VBoxContainer/HBoxContainer/Input.get_text().split("\n")
	var cm = PolyUtils.String_to_Polynomial(input[0])
	input.remove(0)
	var bp_poly_array :Array
	for string in input:
		bp_poly_array.append(PolyUtils.String_to_Polynomial(string))	
	var bp = MatrixUtils.array_to_vector(bp_poly_array)
	
	# Decrypt and format message
	var message_decrypted = SaberPKE.Decrypt(s, [cm, bp])
	var message_formatted = PolyUtils.Polynomial_to_String(message_decrypted).replace(" ", "").rstrip("0")
	$VBoxContainer/HBoxContainer/Output.set_text(message_formatted)
