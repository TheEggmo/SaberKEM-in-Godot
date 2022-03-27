class_name Polynomial
extends Reference

# Use set/get_coefficient() to set/get a coefficient value
# Use add_coefficient() to add to a coefficient instead
# Use add_polynomial() to add polynomials 
# The degrees will wrap around by itself, but the coefficients will not
# Use mod_coefficients() to modulate all coefficients 

# Array of coefficients
var coefficients :Array setget _set_coefficients, _get_coefficients

#var modulo :int = 0
var max_degree :int setget _set_max_degree, _get_max_degree

func _init(max_max_degree :int):
	max_degree = max_max_degree
	
	coefficients.resize(max_degree)
	for deg in range(max_degree):
		coefficients[deg] = 0

# Set coefficients using an array
func read_array(arr : Array):
	arr.resize(max_degree)
	for deg in range(max_degree):
		coefficients[deg] = arr[deg] if arr[deg] != null else 0

func set_coefficient(degree :int,  value :int):
	coefficients[degree % max_degree] = value

func add_coefficient(degree :int, value :int):
	coefficients[degree % max_degree] += value

func get_coefficient(degree :int):
	if degree < max_degree:
		return coefficients[degree]
	print("Error: get_coefficient(): Degree too high")
	return 0

func mod_coefficients(modulo :int):
	for deg in range(max_degree):
		coefficients[deg] = coefficients[deg] % modulo
		while coefficients[deg] < 0:
			coefficients[deg] += modulo

func add_polynomial(other :Polynomial):
	if max_degree != other.max_degree:
		print("Error: add_polynomial(): Polynomials degree mismatch")
		return
	
	for deg in range(max_degree):
		add_coefficient(deg, other.get_coefficient(deg))

func shift_left(amount : int):
	for deg in range(max_degree):
		if sign(coefficients[deg]) < 0:
			print("Warning: shift_left(): Attempting to shift a negative coefficient")
			continue
		coefficients[deg] = coefficients[deg] << amount

func shift_right(amount : int):
	for deg in range(max_degree):
		if sign(coefficients[deg]) < 0: 
			print("Warning: shift_right(): Attempting to shift a negative coefficient")
			continue
		coefficients[deg] = coefficients[deg] >> amount

func _set_max_degree(new :int):
	return
func _get_max_degree():
	return max_degree
func _set_coefficients(new :Array):
	return
func _get_coefficients():
	return coefficients.duplicate(true)
func _to_string():
	return String(coefficients)
