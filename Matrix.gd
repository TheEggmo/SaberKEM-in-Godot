class_name PolyMatrix
extends Reference

var rows setget _set_rows, _get_rows
var columns setget _set_columns, _get_columns
var poly_degree setget _set_poly_degree, _get_poly_degree

var _values :Array

func _init(max_rows :int, max_columns :int, max_poly_degree :int):
	rows = max_rows
	columns = max_columns
	poly_degree = max_poly_degree
	
	for i in range(rows * columns):
		_values.append(Polynomial.new(poly_degree))

func set_value(row :int, column :int, new_value :Polynomial):
	var address = row * self.columns + column
	if self.poly_degree == new_value.max_degree:
		_values[address] = new_value
	else:
		print("Polynomial degree incompatible with matrix degree")

func get_value(row :int, column:int) -> Polynomial:
	var address = row * self.columns + column
	return _values[address]

func matrix_poly_mult(poly :Polynomial) -> Polynomial:
	return null

func mod_values(modulo :int):
	for v in _values:
		v.mod_coefficients(modulo)

func duplicate() -> PolyMatrix:
	var dupe = get_script().new(rows, columns, poly_degree)
	
	for r in rows:
		for c in columns:
			dupe.set_value(r, c, self.get_value(r, c))
	
	return dupe

func shift_left(amount : int):
	for v in _values:
		v.shift_left(amount)

func shift_right(amount : int):
	for v in _values:
		v.shift_right(amount)

func print_values():
	print("Matrix, %s rows, %s columns:" % [rows, columns])
	for row in rows:
		for column in columns:
			var address = row * self.columns + column
			print("[%s,%s]: %s" % [row, column, _values[address]])

func _get_rows():
	return rows
func _set_rows(new :int):
	return
func _get_columns():
	return columns
func _set_columns(new :int):
	return
func _get_poly_degree():
	return poly_degree
func _set_poly_degree(new :int):
	return
