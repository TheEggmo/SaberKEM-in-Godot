extends Node2D

class PublicKey:
	func _init(new_seed, new_b):
		seed_A = new_seed
		b = new_b
	var seed_A 
	var b


func _ready():
	test()
	return
	
	# Initialize h1
	var h1 = Polynomial.new(Params.n)
	var h1_co = pow(2, Params.eq - Params.ep - 1)
	for deg in h1.max_degree:
		h1.set_coefficient(deg, h1_co)
	Params.h1 = h1
	
	#Initialize h2
	var h2 = Polynomial.new(Params.n)
	var h2_co = (pow(2, Params.ep - 2)
	- pow(2, Params.ep - Params.eT - 1)
	+ pow(2, Params.eq - Params.ep - 1))
	for deg in h2.max_degree:
		h2.set_coefficient(deg, h2_co)
	Params.h2 = h2
	
	# Initialize h
	var h = PolyMatrix.new(Params.l, 1, Params.n)
	for r in h.rows:
		h.set_value(r, 0, h1)
	Params.h = h
	
	
	var KeyGen_result = Saber_PKE_KeyGen()
	

#func Saber_PKE_KeyGen(seed_A, seed_sp) -> Array:
func Saber_PKE_KeyGen() -> Array:
	var seed_A = 21372022 # HACK: Temporary hardcoded seed, change later
	var seed_s = 42069 # HACK: Temporary hardcoded seed, change later
	
	var A :PolyMatrix = GenMatrix(seed_A)
	var s :PolyMatrix = GenSecret(seed_s)
	# Transpozycja A, pomnożona przez s, plus h, modulo q, przesunięte w prawo o eq-ep
#	var b :PolyMatrix = (
#	matrix_add(
#		matrix_mult(
#			matrix_transpose(A), s, Params.q), Params.h).mod_values(Params.q).shift_right(Params.eq - Params.ep))
	var b :PolyMatrix = matrix_mult(matrix_transpose(A), s, Params.q)
	b = matrix_add(b, Params.h).mod_values(Params.q)
	b = b.shift_right(Params.eq - Params.ep)
	
	var pk = PublicKey.new(seed_A, b)
	
	return [pk, s]

func Saber_PKE_Enc(m : Message, PublicKey_cpa : PublicKey):
	var seed_A = PublicKey_cpa.seed_A
	var b = PublicKey_cpa.b
	
	var A :PolyMatrix = GenMatrix(seed_A)
	
	var seed_sp = 69420 # HACK: Temporary hardcoded seed, change later
	var sp :PolyMatrix = GenSecret(seed_sp)
	
	var bp :PolyMatrix = matrix_mult(A, sp, Params.q)
	bp = matrix_add(bp, Params.h).mod_values(Params.q)
	bp = bp.shift_right(Params.eq - Params.ep)
	
	var vp = matrix_mult(matrix_transpose(b), sp.mod_values(Params.q))
	
	var cm

func GenMatrix(seed_A) -> PolyMatrix:
	var output_mat = PolyMatrix.new(Params.l, Params.l, Params.n)
	rand_seed(seed_A)
	
	for r in range(Params.l):
		for c in range(Params.l):
			var new_poly = Polynomial.new(Params.n)
			for i in range(Params.n):
				new_poly.set_coefficient(i, randi())
			 
			output_mat.set_value(r, c, new_poly)
	
	output_mat.mod_values(Params.q)
	return output_mat

func GenSecret(seed_sp) -> PolyMatrix:
	var output_vector = PolyMatrix.new(Params.l, 1, Params.n)
	rand_seed(seed_sp)
	
	for r in range(Params.l):
		var new_poly = Polynomial.new(Params.n)
		for i in range(Params.n):
			new_poly.set_coefficient(i, randi())
		
		output_vector.set_value(r, 0, new_poly)
	
	output_vector.mod_values(Params.q)
	return output_vector

func InnerProd():
	pass

func matrix_transpose(original : PolyMatrix) -> PolyMatrix:
	var output = PolyMatrix.new(original.columns, original.rows, original.poly_degree)
	
	for r in original.rows:
		for c in original.columns:
			output.set_value(r, c, original.get_value(c, r))
	
	return output

func matrix_mult(left :PolyMatrix, right :PolyMatrix, output_mod :int) -> PolyMatrix:
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
				sum.add_polynomial(poly_mult(left.get_value(r, k), right.get_value(k, c), 8)) #TODO Remove the '8'
			sum.mod_coefficients(output_mod)
			output.set_value(r, c, sum)
	
	return output

func matrix_add(left :PolyMatrix, right :PolyMatrix) -> PolyMatrix:
	if left.columns != right.columns || left.rows != right.rows:
		print("Incorrect dimensions for matrix addition")
		return null
	if left.poly_degree != right.poly_degree:
		print("Incorrect matrix polynomial degree")
		return null
	
#	var output :PolyMatrix = left.duplicate()
	var output :PolyMatrix = PolyMatrix.new(left.rows, left.columns, left.poly_degree)
	for r in output.rows:
		for c in output.columns:
#			# Calculate the output polynomial for this row and column
			var left_side = left.get_value(r, c)
			var right_side = right.get_value(r, c)
#			var poly_sum = Polynomial.new(output.poly_degree)
#
#			for deg in output.poly_degree:
#				var sum = left_side.get_coefficient(deg) + right_side.get_coefficient(deg)
#				poly_sum.set_coefficient(deg, sum)
#			output.set_value(r, c, poly_sum)
			output.set_value(r, c, poly_add(left_side, right_side))
	
	return output

func poly_mult(left :Polynomial, right :Polynomial, target_degree := Params.n) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("Polynomial multiplication failed, degree mismatch")
		return null
	
	var output = Polynomial.new(target_degree)
	for l in left.max_degree:
		for r in right.max_degree:
			output.add_coefficient(l + r, left.get_coefficient(l) * right.get_coefficient(r))
	
	return output

func poly_add(left :Polynomial, right :Polynomial) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("add_polynomial(): Polynomials degree mismatch")
		return null
	
	var output = Polynomial.new(left.max_degree)
	
	for deg in output.max_degree:
		output.set_coefficient(deg, left.get_coefficient(deg) + right.get_coefficient(deg))
	
	return output

func test():
#	var poly = Polynomial.new(8)
#	poly.set_coefficient(5, 10)
#	poly.set_coefficient(2, 3)
#	poly.mod_coefficients(8)
	
	var p1 = Polynomial.new(8)
	var p2 = Polynomial.new(8)
	var p3 = Polynomial.new(8)
	var p4 = Polynomial.new(8)
#
	p1.set_coefficient(0, 3)
	p1.set_coefficient(1, 5)
	p1.set_coefficient(7, 4)
	p2.set_coefficient(2, 3)
	p2.set_coefficient(4, 10)
##	p2.set_coefficient(6, 9)
	p3.set_coefficient(2, 10)
	p3.set_coefficient(4, 10)
	p4.set_coefficient(2, 50)
	p4.set_coefficient(3, 3)
#
	var m1 = PolyMatrix.new(2, 2, 8)
#	var m2 = PolyMatrix.new(2, 2, 8)
#
	m1.set_value(0, 0, p1)
	m1.set_value(0, 1, p2)
	m1.set_value(1, 0, p3)
	m1.set_value(1, 1, p4)
#	m2.set_value(0, 0, p1)
#	m2.set_value(0, 1, p2)
#	m2.set_value(1, 0, p3)
#	m2.set_value(1, 1, p4)
#
##	var poly_out = poly_mult(p1, p2, 8)
##	poly_out.mod_coefficients(8)
#	var mat_out = matrix_mult(m1, m2, 8)
#	print(p1)
#	p1.shift_right(1)
#	print(p1)
#	p1.shift_left(5)
#	print(p1)
#	m1.print_values()
#	m1.shift_right(2)
#	m1.print_values()
