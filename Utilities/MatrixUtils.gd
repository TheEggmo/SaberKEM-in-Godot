class_name MatrixUtils
extends Object

# Utility functions for matrices and vectors.

# Adds two matrices together and returns the result as a new matrix..
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

# Multiplies two matrices together and returns the result as a new matrix.
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

# Returns a transposed copy of the given matrix.
static func matrix_transpose(original :PolyMatrix) -> PolyMatrix:
	var output = PolyMatrix.new(original.columns, original.rows, original.poly_degree)
	for r in original.rows:
		for c in original.columns:
			output.set_value(c, r, original.get_value(r, c))
	return output

# Converts a 1x1 matrix to a polynomial.
static func matrix_to_poly(input :PolyMatrix) -> Polynomial:
	if input.columns != 1 || input.rows != 1:
		print("Error: matrix_to_poly(): Can't convert")
		return null
	return input.get_value(0,0)

# Generates a matrix with random values with the given paramters.
static func random_matrix(rows :int, columns :int, degree :int, mod :int) -> PolyMatrix:
	var output := PolyMatrix.new(rows, columns, degree)
	for r in rows:
		for c in columns:
			output.set_value(r, c, PolyUtils.random_poly(degree, mod))
	return output

# Returns a copy of the given matrix.
# Matrices are passed by reference, use this if you want to copy a matrix without modyfying the original.
static func duplicate_matrix(input :PolyMatrix) -> PolyMatrix:
	var dupe = PolyMatrix.new(input.rows, input.columns, input.poly_degree)
	for r in input.rows:
		for c in input.columns:
			dupe.set_value(r, c, PolyUtils.duplicate_polynomial(input.get_value(r, c)))
	return dupe

# Converts the given input vector to a string.
static func vector_to_string(input :PolyMatrix, num_length :int) -> String:
	if input.rows != 1 && input.columns != 1:
		print("PolyMatrix.vector_to_string(): Matrix is not a vector")
		return ""
	
	var vec = duplicate_matrix(input)
	if vec.rows == 1:
		vec = matrix_transpose(vec)
	
	var out = ""
	for r in vec.rows:
		out += PolyUtils.poly_to_numstring(vec.get_value(r, 0), num_length)
	return out

# Converts a string of numbers to a vector
static func numstring_to_vector(input :String, num_length :int, row_count :int, poly_degree :int):
	var numbers = Utils.split_string(input, num_length)
	var out = PolyMatrix.new(row_count, 1, poly_degree)
	var k = 0
	for i in row_count:
		out.get_value(i, 0).set_coefficient(k, numbers[k].to_int())
		k += 1
	return out

# Converts a vector to an array of polynomials.
static func vector_to_array(input :PolyMatrix) -> Array:
	var vector = duplicate_matrix(input)
	if vector.columns > 1:
		if vector.rows == 1:
			vector = matrix_transpose(vector)
		else:
			print("vector_to_array(): input is not a vector")
			return []
	var output :Array
	for r in vector.rows:
		output.append(vector.get_value(r, 0))
	return output
