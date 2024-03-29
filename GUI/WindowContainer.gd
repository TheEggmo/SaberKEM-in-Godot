extends BoxContainer

enum WindowType {
	KeyGen,
	Enc,
	Dec
}

var window_keygen = preload("res://GUI/KeyGen.tscn")
var window_encryption = preload("res://GUI/Encryption.tscn")
var window_decryption = preload("res://GUI/Decryption.tscn")

func _ready():
	new_window(0)
	new_window(1)
	new_window(2)

func new_window(type : int):
	var window
	match type:
		WindowType.KeyGen:
			window = window_keygen.duplicate(true).instance()
		WindowType.Enc:
			window = window_encryption.duplicate(true).instance()
		WindowType.Dec:
			window = window_decryption.duplicate(true).instance()
		_: # Default
			return
	add_child(window)
	add_child(HSeparator.new())
	move_child($NewWindowMenu,get_child_count()-1)

func _on_NewKeygenButton_pressed():
	new_window(WindowType.KeyGen)

func _on_NewEncButton_pressed():
	new_window(WindowType.Enc)

func _on_NewDecButton_pressed():
	new_window(WindowType.Dec)
