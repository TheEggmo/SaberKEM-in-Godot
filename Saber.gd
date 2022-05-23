extends Node

class PublicKey:
	var seed_A :int
	var b :PolyMatrix
	func _init(new_seed, new_b):
		seed_A = new_seed
		b = new_b

func _ready():
	return
#	randomize()
	# Initialize message for encryption/decryption
	var bits : Array
	for i in Params.n:
		bits.append(0)
	BitUtils.randomize_bitarray(bits)
	var m = Polynomial.new(Params.n)
	m.read_array(bits)
#	m.read_array([0,1,0,1,0,0,1,1])
#	m.read_array([0,0,0,0,1,1,1,1])
	print("Input message: %s\n" % m)
	
#	randomize()
	var KeyGen_result = Saber_PKE_KeyGen()
	var Enc_result = Saber_PKE_Enc(PolyUtils.duplicate_polynomial(m), KeyGen_result[0])
	var Dec_result = Saber_PKE_Dec(KeyGen_result[1], Enc_result)
	
	print("Decrypted message: %s\n" % Dec_result)
	
	var error_rate = PolyUtils.compare_polynomials(m, Dec_result)
	print("Algorithm finished!")
	print("Error rate : %s %%" % (error_rate))

#func Saber_PKE_KeyGen(seed_A, seed_sp) -> Array:
func Saber_PKE_KeyGen() -> Array:
#	var seed_A = 21372022 # HACK: Temporary hardcoded seed, change later
#	var seed_s = 42069 # HACK: Temporary hardcoded seed, change later
	var seed_A = randi()
	var seed_s = randi()
	
	var A :PolyMatrix = GenMatrix(seed_A)
	var s :PolyMatrix = GenSecret(seed_s)
	
	# b = ((A^T * s + h) mod q) >> (eq - ep)
	var b :PolyMatrix = MatrixUtils.matrix_mult(MatrixUtils.matrix_transpose(A), s, Params.q)
	b = MatrixUtils.matrix_add(b, Params.h)
	b.mod_values(Params.q)
	b.shift_right(Params.eq - Params.ep)
	
	var pk = PublicKey.new(seed_A, b)
	
	return [pk, s]

func Saber_PKE_Enc(m :Polynomial, PublicKey_cpa :PublicKey):
	var seed_A = PublicKey_cpa.seed_A
	var b = PublicKey_cpa.b
	
	var A :PolyMatrix = GenMatrix(seed_A)
	
	var seed_sp = 69420 # HACK: Temporary hardcoded seed, change later
	var sp :PolyMatrix = GenSecret(seed_sp)
	
	# bp = ((A * sp + h) mod q) >> (eq - ep)
	var bp :PolyMatrix = MatrixUtils.matrix_mult(A, sp, Params.q)
	bp = MatrixUtils.matrix_add(bp, Params.h)
	bp.mod_values(Params.q)
	bp.shift_right(Params.eq - Params.ep)
	
	# vp = b^T * (sp mod p)
	sp.mod_values(Params.p)
#	sp.print_values() # delete later
	var vp = MatrixUtils.matrix_mult(MatrixUtils.matrix_transpose(b), sp, Params.p)
	vp = MatrixUtils.matrix_to_poly(vp)
	
	# cm = (vp + h1 - (2^(ep - 1) * m mod p)) >> (ep - eT)
	var cm :Polynomial = PolyUtils.poly_add(vp, Params.h1)
	m.shift_left(Params.ep - 1)
	cm = PolyUtils.poly_sub(cm, m)
	cm.mod_coefficients(Params.p)
	cm.shift_right(Params.ep - Params.eT)
	
	return [cm, bp]

func Saber_PKE_Dec(s :PolyMatrix, c :Array):
	var cm :Polynomial = c[0]
	var bp :PolyMatrix = c[1]
	
	# v = bp^T * (s mod p)
	s.mod_values(Params.p)
	var v = MatrixUtils.matrix_mult(MatrixUtils.matrix_transpose(bp), s, Params.p)
	v = MatrixUtils.matrix_to_poly(v)
	v.mod_coefficients(Params.p)
	
	# mp = ((v - (2^(ep - eT) * cm) + h2) mod p) >> (ep - 1)
	var mp :Polynomial = PolyUtils.poly_add(v, Params.h2)
	cm.shift_left(Params.ep - Params.eT)
	mp = PolyUtils.poly_sub(mp, cm)
	mp.mod_coefficients(Params.p)
	mp.shift_right(Params.ep-1)
	
	return mp

func GenMatrix(seed_A) -> PolyMatrix:
	var output_mat = PolyMatrix.new(Params.l, Params.l, Params.n)
	seed(seed_A)
	
	var buf = BitUtils.create_bytearray(Params.l * Params.l * Params.n * Params.eq / 8)
	BitUtils.randomize_bitarray(buf)
	var buf_array = BitUtils.split_bitarray(buf, Params.eq)
	
	var k = 0
	for i1 in Params.l:
		for i2 in Params.l:
			for j in Params.n:
				output_mat.get_value(i1, i2).set_coefficient(j, BitUtils.bitarray_to_int(buf_array[k]))
				k += 1
	
	output_mat.mod_values(Params.q)
	return output_mat

# Generuje klucz prywatny za pomocą rozkładu dwumianowego
func GenSecret(seed_sp) -> PolyMatrix:
	var output_vector = PolyMatrix.new(Params.l, 1, Params.n)
	seed(seed_sp)
	
	var buf = BitUtils.create_bytearray(Params.l * Params.n * Params.mi / 8)
	BitUtils.randomize_bitarray(buf)
	var buf_array = BitUtils.split_bitarray(buf, Params.mi / 2)
	
	var k = 0
	for i in Params.l: # Dla każdego elementu wektora
		for j in Params.mi: # Dla każdego współczynnika wielomianu
			output_vector.get_value(i,0).set_coefficient(j,HammingWeight(buf_array[k]) - HammingWeight(buf_array[k+1]))
			k += 2
	
	output_vector.mod_values(Params.q)
	return output_vector

# Liczy ilość niezerowych elementów. Używać z tablicami liczb
func HammingWeight(input : Array) -> int:
	return input.size() - input.count(0)

