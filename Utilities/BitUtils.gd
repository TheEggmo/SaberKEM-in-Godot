class_name BitUtils
extends Object

# Losowo ustaw wszystkie zmienne w tablicy na 1 lub 0
# Zastępca SHAKE-128
static func randomize_bitarray(input : Array):
	for i in input.size():
		input[i] = randi() % 2

# Utwórz tablicę zer o długości length*8
static func create_bytearray(length : int) -> Array:
	var out : Array
	for i in length*8:
		out.append(0)
	return out

static func split_bitarray(input : Array, segment_length :int, padding := true) -> Array:
	var dup = input.duplicate(true)
	var out : Array
	var i = 0
	if padding:
		while dup.size() % segment_length != 0:
			dup.append(0)
	while i < dup.size():
		out.append(dup.slice(i, i + segment_length - 1))
		i += segment_length
	return out

# Zamienia tablicę bitów na int
# Zakłada się użycie tablicy pełnej zer i jedynek o długości 8, ale nie jest to sprawdzane
static func bitarray_to_int(input : Array) -> int:
	var out = 0
	for i in input.size():
		out += input[i] * pow(2, i)
	return out
