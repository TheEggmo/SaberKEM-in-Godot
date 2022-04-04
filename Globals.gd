extends Node

enum verbose{
	None, # Only print error and warnings
	Results, # Print all polynomials and matrices after they are calculated
	Everything # Print every step of calculations
}

var _verbose_level :int = 0

func set_verbose_level(level :int):
	_verbose_level = clamp(level, 0, 2)

func check_verbose_level(level :int):
	return _verbose_level >= level
