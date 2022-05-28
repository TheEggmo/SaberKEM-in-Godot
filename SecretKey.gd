class_name SecretKey
extends Key

# Wektor wielomianów, który służy jako klucz prywatny
var values :PolyMatrix

func _init(secret_key :PolyMatrix):
	values = secret_key

func _to_string():
	return MatrixUtils.vector_to_string(values, str(Params.q).length())
