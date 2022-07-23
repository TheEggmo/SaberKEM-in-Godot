class_name PolyUtils
extends Object

# Adds two polynomials together.
# Returns the result as a new polynomial.
static func poly_add(left :Polynomial, right :Polynomial) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("Error: poly_add(): Polynomials degree mismatch")
		return null
	
	var output = Polynomial.new(left.max_degree)
	
	for deg in output.max_degree:
		output.set_coefficient(deg, left.get_coefficient(deg) + right.get_coefficient(deg))
	
	return output

# Subtracts the right polynomial from the left.
# Returns the result as a new polynomial.
static func poly_sub(left :Polynomial, right :Polynomial) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("Error: poly_sub(): Polynomials degree mismatch")
		return null
	
	var output = Polynomial.new(left.max_degree)
	
	for deg in output.max_degree:
		output.set_coefficient(deg, left.get_coefficient(deg) - right.get_coefficient(deg))
	
	return output

# Multiplies together two polynomials.
# Returns the result as a new polynomial.
# target_degree specifies the degree of the returned polynomial.
static func poly_mult(left :Polynomial, right :Polynomial, target_degree := Params.n) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("Polynomial multiplication failed, degree mismatch")
		return null
	
	var output = Polynomial.new(target_degree)
	for l in left.max_degree:
		for r in right.max_degree:
			output.add_coefficient(l + r, left.get_coefficient(l) * right.get_coefficient(r))
	
	return output

# Generates a polynomial with random positive coefficients.
static func random_poly(degree :int, mod :int) -> Polynomial:
	var output := Polynomial.new(degree)
	for d in degree:
		output.set_coefficient(d, randi())
	output.mod_coefficients(mod)
	return output

# Generates a polynomial with random coefficients.
static func random_poly_negatives(degree :int, mod :int) -> Polynomial:
	var output := Polynomial.new(degree)
	for d in degree:
		if randi() % 2 == 0:
			output.set_coefficient(d, randi())
		else:
			output.set_coefficient(d, -1 * randi())
	return output

# Duplicates the given polynomial.
# Polynomials are passed by reference, use this if you want to copy a polynomial without modyfying the original.
static func duplicate_polynomial(input :Polynomial) -> Polynomial:
	var dupe := Polynomial.new(input.max_degree)
	for deg in input.max_degree:
		dupe.set_coefficient(deg, input.get_coefficient(deg))
	return dupe

# Returns the percentage difference between the two polynomials.
static func compare_polynomials(left :Polynomial, right :Polynomial) -> float:
	if left.max_degree != right.max_degree:
		print("compare_polynomials(): Polynomials have different degrees!")
		return 1.0
	var fails = 0
	for deg in left.max_degree:
		if left.get_coefficient(deg) != right.get_coefficient(deg):
			fails += 1
	return fails / left.max_degree

# Converts a polynomial to a string of numbers.
static func Polynomial_to_String(poly :Polynomial) -> String:
	var out = ""
	for c in poly.coefficients:
		out += str(c) + " "
	return out.strip_edges()

static func String_to_Polynomial(string :String) -> Polynomial:
	var numbers = string.split(" ")
	var out :Polynomial = Polynomial.new(numbers.size()) 
	for i in numbers.size():
		out.set_coefficient(i, numbers[i].to_int())
	return out
