class_name KeyPair
extends Reference

var public : PublicKey
var secret : SecretKey 

func _init(public_key :PublicKey, secret_key :SecretKey):
	public = public_key
	secret = secret_key
