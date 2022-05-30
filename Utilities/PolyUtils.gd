class_name PolyUtils
extends Object

static func poly_add(left :Polynomial, right :Polynomial) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("Error: poly_add(): Polynomials degree mismatch")
		return null
	
	var output = Polynomial.new(left.max_degree)
	
	for deg in output.max_degree:
		output.set_coefficient(deg, left.get_coefficient(deg) + right.get_coefficient(deg))
	
	return output

static func poly_sub(left :Polynomial, right :Polynomial) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("Error: poly_sub(): Polynomials degree mismatch")
		return null
	
	var output = Polynomial.new(left.max_degree)
	
	for deg in output.max_degree:
		output.set_coefficient(deg, left.get_coefficient(deg) - right.get_coefficient(deg))
	
	return output

static func poly_mult(left :Polynomial, right :Polynomial, target_degree := Params.n) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("Polynomial multiplication failed, degree mismatch")
		return null
	
	var output = Polynomial.new(target_degree)
	for l in left.max_degree:
		for r in right.max_degree:
			output.add_coefficient(l + r, left.get_coefficient(l) * right.get_coefficient(r))
	
	return output

static func random_poly(degree :int, mod :int) -> Polynomial:
	var output := Polynomial.new(degree)
	for d in degree:
		output.set_coefficient(d, randi())
	output.mod_coefficients(mod)
	return output

static func random_poly_negatives(degree :int, mod :int) -> Polynomial:
	var output := Polynomial.new(degree)
	for d in degree:
		if randi() % 2 == 0:
			output.set_coefficient(d, randi())
		else:
			output.set_coefficient(d, -1 * randi())
#	output.mod_coefficients(mod)
	return output

static func duplicate_polynomial(input :Polynomial) -> Polynomial:
	var dupe := Polynomial.new(input.max_degree)
	for deg in input.max_degree:
		dupe.set_coefficient(deg, input.get_coefficient(deg))
	return dupe

# Zwraca procentową różnice między dwoma wielomianami
static func compare_polynomials(left :Polynomial, right :Polynomial) -> float:
	if left.max_degree != right.max_degree:
		print("compare_polynomials(): Polynomials have different degrees!")
		return 1.0
	var fails = 0
	for deg in left.max_degree:
		if left.get_coefficient(deg) != right.get_coefficient(deg):
			fails += 1
	return fails / left.max_degree

# Zamienia wielomian na string liczb
# Dla zachowania odpowiedniego formatu stringa mniejsze liczby mają dodane zera z przodu 
static func poly_to_numstring(poly :Polynomial, num_length :int) -> String:
	var out = ""
	for c in poly.coefficients:
		out += str(c).pad_zeros(num_length)
	return out

## Zamienia string liczb na wielomian
#static func numstring_to_poly(string :String, num_length :int) -> Polynomial:
##	# Podziel string na równe cześci o długości num_length
#	var numbers = Utils.split_string(string, num_length)
##	var i = 0
##	while i < string.length():
##		var substring = ""
##		for j in range(i, i + num_length - 1):
##			substring += string[j]
##		numbers.append(substring)
##		i += num_length
#
#	# Zamień tablice stringów na wielomian
#	var out = Polynomial.new(Params.n)
##	for c in out.coefficients.size()-1: # FIX Ogarnąć to że za krótkie wiadomości crashują
#	for c in 4:
#		out.set_coefficient(c, numbers[c].to_int())
#
#	return out

## Zamienia PoolByteArray na wielomian. 
## Wyjściowy wielomian będzie miał bitowe współczynniki
#static func PoolByteArray_to_polynomial(bytes :PoolByteArray) -> Polynomial:
#	var bits :Array
#	for byte in bytes:
#		bits.append_array(Utils.utf8_character_to_BitArray(byte))
#	var output = Polynomial.new(bytes.size() - 1)
#	return output

static func Array_to_Polynomial(input :Array) -> Polynomial:
	var output = Polynomial.new(input.size())
	for deg in input.size():
		output.set_coefficient(deg, input[deg])
	return output

static func Polynomial_to_Array(input :Polynomial) -> Array:
	return input.coefficients
