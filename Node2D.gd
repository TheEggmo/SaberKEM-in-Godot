extends Node2D

enum verbose{
	None, # Only print error and warnings
	Results, # Print all polynomials and matrices after they are calculated
	Everything # Print every step of calculations
}

export(verbose) var verbose_level :int = 0

class PublicKey:
	var seed_A :int
	var b :PolyMatrix
	func _init(new_seed, new_b):
		seed_A = new_seed
		b = new_b

func _ready():
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
	
	if verbose_level >= verbose.Results:
		print("Params:")
		print("eq: %s\nep: %s\neT: %s\n" % [Params.eq, Params.ep, Params.eT])
		print("h:")
		Params.h.print_values()
		print("h1: %s" % Params.h1)
		print("h2: %s\n" % Params.h2)
	
	# Initialize message for encryption/decryption
	var m = Polynomial.new(Params.n)
	m.read_array([0,1,0,1,0,0,1,1])
	print("Input message: %s\n" % m)
	
	var KeyGen_result = Saber_PKE_KeyGen()
	var Enc_result = Saber_PKE_Enc(m, KeyGen_result[0])
	var Dec_result = Saber_PKE_Dec(KeyGen_result[1], Enc_result)
	
	print("Decrypted message: %s\n" % Dec_result)

#func Saber_PKE_KeyGen(seed_A, seed_sp) -> Array:
func Saber_PKE_KeyGen() -> Array:
	if verbose_level > verbose.None:
		print("KeyGen:\n")
	
	var seed_A = 21372022 # HACK: Temporary hardcoded seed, change later
	var seed_s = 42069 # HACK: Temporary hardcoded seed, change later
	
	var A :PolyMatrix = GenMatrix(seed_A)
	var s :PolyMatrix = GenSecret(seed_s)
	
	if verbose_level >= verbose.Results:
		print("KeyGen: A:")
		A.print_values()
		print("KeyGen: s:")
		s.print_values()
	
	# b = ((A^T * s + h) mod q) >> (eq - ep)
	var b :PolyMatrix = Utils.matrix_mult(Utils.matrix_transpose(A), s, Params.q)
	b = Utils.matrix_add(b, Params.h)
	b.mod_values(Params.q)
	b.shift_right(Params.eq - Params.ep)
	b.mod_values(Params.p) # Might be unnecessary
	
	if verbose_level >= verbose.Results:
		print("KeyGen: b:")
		b.print_values()
	
	var pk = PublicKey.new(seed_A, b)
	
	return [pk, s]

func Saber_PKE_Enc(m :Polynomial, PublicKey_cpa :PublicKey):
	if verbose_level > verbose.None:
		print("Encryption:\n")
	
	var seed_A = PublicKey_cpa.seed_A
	var b = PublicKey_cpa.b
	
	var A :PolyMatrix = GenMatrix(seed_A)
	
	var seed_sp = 69420 # HACK: Temporary hardcoded seed, change later
	var sp :PolyMatrix = GenSecret(seed_sp)
	
	if verbose_level >= verbose.Results:
		print("Enc: A:")
		A.print_values()
		print("Enc: sp:")
		sp.print_values()
	
	# bp = ((A * sp + h) mod q) >> (eq - ep)
	var bp :PolyMatrix = Utils.matrix_mult(A, sp, Params.q)
	bp = Utils.matrix_add(bp, Params.h)
	bp.mod_values(Params.q)
	bp.shift_right(Params.eq - Params.ep)
	bp.mod_values(Params.p) # Might be unnecessary
	
	# vp = b^T * (sp mod q)
	sp.mod_values(Params.p)
	var vp = Utils.matrix_mult(Utils.matrix_transpose(b), sp, Params.p)
	vp = Utils.matrix_to_poly(vp)
	
	if verbose_level >= verbose.Results:
		print("Enc: bp:")
		bp.print_values()
		print("Enc: vp: %s\n" % vp)
	
	# cm = (vp + h1 - (2^(ep - 1) * m mod p)) >> (ep - eT)
	var cm :Polynomial = Utils.poly_add(vp, Params.h1)
	m.shift_left(Params.ep - 1)
	m.mod_coefficients(Params.p)
	cm = Utils.poly_sub(cm, m)
	cm.mod_coefficients(Params.T)
	cm.shift_right(Params.ep - Params.eT)
	cm.mod_coefficients(Params.eT) # Might be unnecessary
	
	if verbose_level >= verbose.Results:
		print("Enc: cm: %s\n" % cm)
	
	return [cm, bp]

func Saber_PKE_Dec(s :PolyMatrix, c :Array):
	if verbose_level > verbose.None:
		print("Decryption:\n")
	
	var cm :Polynomial = c[0]
	var bp :PolyMatrix = c[1]
	
	# v = bp^T * (s mod p)
	s.mod_values(Params.p)
	var v = Utils.matrix_mult(Utils.matrix_transpose(bp), s, Params.p)
	v = Utils.matrix_to_poly(v)
	v.mod_coefficients(Params.p)
	
	if verbose_level >= verbose.Results:
		print("Dec: v: %s\n" % v)
	
	# mp = ((v - (2^(ep - eT) * cm) + h2) mod p) >> (ep - 1)
	var mp :Polynomial = Utils.poly_add(v, Params.h2)
	cm.shift_left(Params.ep - Params.eT)
	mp = Utils.poly_sub(mp, cm)
	mp.mod_coefficients(Params.p)
	mp.shift_right(Params.ep-1)
	mp.mod_coefficients(2)
	
	return mp

func GenMatrix(seed_A) -> PolyMatrix:
	var output_mat = PolyMatrix.new(Params.l, Params.l, Params.n)
	seed(seed_A)
	
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
	seed(seed_sp)
	
	for r in range(Params.l):
		var new_poly = Polynomial.new(Params.n)
		for i in range(Params.n):
			new_poly.set_coefficient(i, randi())
	
		output_vector.set_value(r, 0, new_poly)
	
	output_vector.mod_values(Params.q)
	return output_vector
