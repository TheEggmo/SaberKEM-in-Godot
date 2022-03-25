extends Node2D

class PublicKey:
	func _init(new_seed, new_b):
		seed_A = new_seed
		b = new_b
	var seed_A 
	var b


func _ready():
#	test()
	
	
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
	
	# Initialize message for encryption/decryption
	var m = Polynomial.new(Params.n)
	m.read_array([0,1,0,1,0,0,1,1])
	print(m)
	
	var KeyGen_result = Saber_PKE_KeyGen()
	var Enc_result = Saber_PKE_Enc(m, KeyGen_result[0])
	var Dec_result = Saber_PKE_Dec(KeyGen_result[1], Enc_result)
	print(Dec_result)

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
	b = matrix_add(b, Params.h)
	b.mod_values(Params.q)
	b.shift_right(Params.eq - Params.ep)
	b.mod_values(Params.p)
	
	var pk = PublicKey.new(seed_A, b)
	
	return [pk, s]

func Saber_PKE_Enc(m :Polynomial, PublicKey_cpa :PublicKey):
	var seed_A = PublicKey_cpa.seed_A
	var b = PublicKey_cpa.b
	
	var A :PolyMatrix = GenMatrix(seed_A)
	
	var seed_sp = 69420 # HACK: Temporary hardcoded seed, change later
	var sp :PolyMatrix = GenSecret(seed_sp)
	
	var bp :PolyMatrix = matrix_mult(A, sp, Params.q)
	bp = matrix_add(bp, Params.h)
	bp.mod_values(Params.q)
	bp.shift_right(Params.eq - Params.ep)
	bp.mod_values(Params.p)
	
	sp.mod_values(Params.p)
	var vp = matrix_mult(matrix_transpose(b), sp, Params.p)
	vp = matrix_to_poly(vp)
	
	var cm :Polynomial = poly_add(vp, Params.h1)
	m.shift_left(Params.ep - 1)
	m.mod_coefficients(Params.p)
	cm = poly_sub(cm, m)
	cm.shift_right(Params.ep - Params.eT)
	cm.mod_coefficients(Params.eT)
	
	return [cm, bp]

func Saber_PKE_Dec(s :PolyMatrix, c :Array):
	var cm :Polynomial = c[0]
	var bp :PolyMatrix = c[1]
	
	s.mod_values(Params.p)
	var v = matrix_mult(matrix_transpose(bp), s, Params.p)
	v = matrix_to_poly(v)
	v.mod_coefficients(Params.p)
	
	var mp :Polynomial = poly_add(v, Params.h2)
	cm.shift_left(Params.ep - Params.eT)
	mp = poly_sub(mp, cm)
	mp.mod_coefficients(Params.p)
	mp.shift_right(Params.ep-1)
	mp.mod_coefficients(2)
	
	return mp

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

func matrix_transpose(original :PolyMatrix) -> PolyMatrix:
	var output = PolyMatrix.new(original.columns, original.rows, original.poly_degree)
	
	for r in original.rows:
		for c in original.columns:
			output.set_value(c, r, original.get_value(r, c))
	
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
				sum.add_polynomial(poly_mult(left.get_value(r, k), right.get_value(k, c)))
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
		print("Error: poly_add(): Polynomials degree mismatch")
		return null
	
	var output = Polynomial.new(left.max_degree)
	
	for deg in output.max_degree:
		output.set_coefficient(deg, left.get_coefficient(deg) + right.get_coefficient(deg))
	
	return output

func poly_sub(left :Polynomial, right :Polynomial) -> Polynomial:
	if left.max_degree != right.max_degree:
		print("Error: poly_sub(): Polynomials degree mismatch")
		return null
	
	var output = Polynomial.new(left.max_degree)
	
	for deg in output.max_degree:
		output.set_coefficient(deg, left.get_coefficient(deg) - right.get_coefficient(deg))
	
	return output

func matrix_to_poly(input :PolyMatrix) -> Polynomial:
	if input.columns != 1 || input.rows != 1:
		print("Error: matrix_to_poly(): Can't convert")
		return null
	return input.get_value(0,0)

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
	return
