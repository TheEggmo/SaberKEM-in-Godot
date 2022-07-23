class_name Utils
extends Object

# Split a string into segments of length segment_length
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

# Returns the ammount of non-zero elements in the given array.
static func HammingWeight(input : Array) -> int:
	return input.size() - input.count(0)
