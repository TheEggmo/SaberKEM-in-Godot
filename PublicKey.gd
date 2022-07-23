class_name PublicKey
extends Key

var seed_A :int
var b :PolyMatrix

func _init(new_seed, new_b):
	seed_A = new_seed
	b = new_b

func _to_string():
	var out = ""
	out += str(seed_A)
	out += "\n"
	out += MatrixUtils.vector_to_string(b)
	return out
