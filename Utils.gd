class_name Utils
extends Reference

# Utility functions for matrices and polynomials

static func matrix_transpose(original :PolyMatrix) -> PolyMatrix:
	var output = PolyMatrix.new(original.columns, original.rows, original.poly_degree)
	
	for r in original.rows:
		for c in original.columns:
			output.set_value(c, r, original.get_value(r, c))
	
	return output

static func matrix_mult(left :PolyMatrix, right :PolyMatrix, output_mod :int) -> PolyMatrix:
	if left.columns != right.rows:
		print("Incorrect dimensions for matrix multiplication")
		return null
	if left.poly_degree != right.poly_degree:
		print("Incorrect matrix polynomial degree")
		return null
	
	var output = PolyMatrix.new(left.rows, right.columns, left.poly_degree)
	
	for r in output.rows:
		for c in output.columns:
			var sum = Polynomial.new(output.poly_degree)
			for k in left.columns:
				sum.add_polynomial(poly_mult(left.get_value(r, k), right.get_value(k, c)))
			sum.mod_coefficients(output_mod)
			output.set_value(r, c, sum)
	
	return output

static func matrix_add(left :PolyMatrix, right :PolyMatrix) -> PolyMatrix:
	if left.columns != right.columns || left.rows != right.rows:
		print("Incorrect dimensions for matrix addition")
		return null
	if left.poly_degree != right.poly_degree:
		print("Incorrect matrix polynomial degree")
		return null
	
	var output :PolyMatrix = PolyMatrix.new(left.rows, left.columns, left.poly_degree)
	for r in output.rows:
		for c in output.columns:
#			# Calculate the output polynomial for this row and column
			var left_side = left.get_value(r, c)
			var right_side = right.get_value(r, c)
			output.set_value(r, c, poly_add(left_side, right_side))
	
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

# Convert a 1x1 matrix to a polynomial
# Used after multyplying two vectors
static func matrix_to_poly(input :PolyMatrix) -> Polynomial:
	if input.columns != 1 || input.rows != 1:
		print("Error: matrix_to_poly(): Can't convert")
		return null
	return input.get_value(0,0)

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

static func random_matrix(rows :int, columns :int, degree :int, mod :int) -> PolyMatrix:
	var output := PolyMatrix.new(rows, columns, degree)
	for r in rows:
		for c in columns:
			output.set_value(r, c, random_poly(degree, mod))
	return output

static func duplicate_matrix(input :PolyMatrix) -> PolyMatrix:
	var dupe = PolyMatrix.new(input.rows, input.columns, input.poly_degree)
	for r in input.rows:
		for c in input.columns:
			dupe.set_value(r, c, duplicate_polynomial(input.get_value(r, c)))
	return dupe

static func duplicate_polynomial(input :Polynomial) -> Polynomial:
	var dupe := Polynomial.new(input.max_degree)
	for deg in input.max_degree:
		dupe.set_coefficient(deg, input.get_coefficient(deg))
	return dupe

static func compare_polynomials(left :Polynomial, right :Polynomial) -> bool:
	if Globals.check_verbose_level(1): # Debugging mode
		var out = true
		for deg in left.max_degree:
			if left.get_coefficient(deg) != right.get_coefficient(deg):
				print("Warning: compare_polynomials: degree mismatch - %s" % deg)
				out = false
		return false
	for deg in left.max_degree: # Normal mode
		if left.get_coefficient(deg) != right.get_coefficient(deg):
			return false
	return true
