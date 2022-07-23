extends Node

# Takes the input message and key and returns encrypted message
func _on_Button_pressed():
	# Convert public key string into PublicKey object
	var pk :Array = $VBoxContainer/PublicKey.get_text().split("\n")
	var keyseed = pk[0] # seedA
	var numstrings = pk
	numstrings.remove(0)
	var poly_array : Array
	for string in numstrings:
		poly_array.append(PolyUtils.String_to_Polynomial(string))
	var public_key = PublicKey.new(keyseed.to_int(), MatrixUtils.array_to_vector(poly_array))
	
	# Run encryption on the input message
	var message :String = $VBoxContainer/HBoxContainer/Input.get_text()
	var message_encrypted = run_encryption(message, public_key)
	
	$VBoxContainer/HBoxContainer/Output.set_text(message_encrypted)

# Runs encryption on the given message and key and returns the result
# The string is formatted for proper functionality
func run_encryption(message :String, key :PublicKey) -> String:
	var message_formatted = format_message(message)
	var message_poly = Polynomial.new(Params.n)
	for i in Params.n:
		message_poly.set_coefficient(i, message_formatted[i].to_int())
	var encryption_output = SaberPKE.Encrypt(message_poly, key)
	var message_encrypted = encryption_output[0] # cm
	var bp = encryption_output[1]
	
	var output :String = PolyUtils.Polynomial_to_String(message_encrypted) + "\n"
	output += MatrixUtils.vector_to_string(bp)
	
	return output

# Pads or removes excess letters in string
func format_message(input :String) -> String:
	var out :String = input
	if out.length() > Params.n:
		# Erase all excess characters
		out.erase(Params.n, input.length() - Params.n)
	else:
		# Pad characters until length is 256
		while out.length() < 256:
			out += "0"
	return out
