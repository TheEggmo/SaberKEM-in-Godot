class_name Utils
extends Object

# Podziel string na cześci o długości segment_length
static func split_string(input :String, segment_length :int) -> Array:
	var output :Array
	var i = 0
	while i < input.length():
		var substring = ""
		for j in range(i, i + segment_length - 1):
			substring += input[j]
		output.append(substring)
		i += segment_length
	return output

# Podziel tablicę na części o długości segment_length
static func split_array(input :Array, segment_length :int, padding := true) -> Array:
	var output :Array
	var i = 0
	while i < input.size():
		output.append(input.slice(i, i + segment_length - 1))
		i += segment_length
	if padding:
		var back :Array = output.back()
		if back.size() < segment_length:
			var filler :Array
			filler.resize(segment_length - back.size())
			for j in filler.size():
				filler[j] = 0
			back.append_array(filler)
	return output

# Zamienia literę w formacie utf-8 na tablicę bitów.
# Zwracana tablica ma długość 16.
# Zakładane jest użycie poprawnych danych wejściowych.
static func Byte_to_BitArray(input :int) -> Array:
	var output :Array
	while input > 0:
		output.append(input % 2)
		input /= 2
	while output.size() < 16:
		output.append(0)
	return output

static func BitArray_to_Byte(input :Array) -> int:
	var output = 0
	for i in input.size():
		output += 2 * i * input[i] 
	return output

static func PoolByteArray_to_BitArray(input :PoolByteArray) -> Array:
	var output :Array
	for byte in input:
		output.append_array(Byte_to_BitArray(byte))
	return output

static func BitArray_to_PoolByteArray(input :Array) -> PoolByteArray:
	var output :PoolByteArray
	var bytes = split_array(input, 16)
	for byte in bytes:
		output.append(BitArray_to_Byte(byte))
	return output
