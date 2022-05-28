class_name MatrixUtils
extends Reference

# Utility functions for matrices and polynomials

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
			output.set_value(r, c, PolyUtils.poly_add(left_side, right_side))
	
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
				sum.add_polynomial(PolyUtils.poly_mult(left.get_value(r, k), right.get_value(k, c)))
			sum.mod_coefficients(output_mod)
			output.set_value(r, c, sum)
	
	return output

static func matrix_transpose(original :PolyMatrix) -> PolyMatrix:
	var output = PolyMatrix.new(original.columns, original.rows, original.poly_degree)
	for r in original.rows:
		for c in original.columns:
			output.set_value(c, r, original.get_value(r, c))
	return output

# Convert a 1x1 matrix to a polynomial
# Used after multyplying two vectors
static func matrix_to_poly(input :PolyMatrix) -> Polynomial:
	if input.columns != 1 || input.rows != 1:
		print("Error: matrix_to_poly(): Can't convert")
		return null
	return input.get_value(0,0)

static func random_matrix(rows :int, columns :int, degree :int, mod :int) -> PolyMatrix:
	var output := PolyMatrix.new(rows, columns, degree)
	for r in rows:
		for c in columns:
			output.set_value(r, c, PolyUtils.random_poly(degree, mod))
	return output

static func duplicate_matrix(input :PolyMatrix) -> PolyMatrix:
	var dupe = PolyMatrix.new(input.rows, input.columns, input.poly_degree)
	for r in input.rows:
		for c in input.columns:
			dupe.set_value(r, c, PolyUtils.duplicate_polynomial(input.get_value(r, c)))
	return dupe

static func vector_to_string(input :PolyMatrix, num_length :int) -> String:
	if input.rows != 1 && input.columns != 1:
		print("PolyMatrix.vector_to_string(): Matrix is not a vector")
		return ""
	
	var vec = duplicate_matrix(input)
	if vec.rows == 1:
		vec = matrix_transpose(vec)
	
	var out = ""
	for r in vec.rows:
		out += PolyUtils.convert_to_numstring(vec.get_value(r, 0), num_length)
	return out
