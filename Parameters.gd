extends Node

const n = 256

const l = 3

var h :PolyMatrix = null
var h1 :Polynomial = null
var h2 :Polynomial = null

var q = pow(2, eq)
var p = pow(2, ep)
var T = pow(2, eT)

# eq > ep > eT
const eq = 13
const ep = 10
const eT = 4

const mi = 8

func _ready():
	# Initialize h1
	var h1 = Polynomial.new(Params.n)
	var h1_co = pow(2, Params.eq - Params.ep - 1)
	for deg in h1.max_degree:
		h1.set_coefficient(deg, h1_co)
	Params.h1 = h1
	
	#Initialize h2
	var h2 = Polynomial.new(Params.n)
	var h2_co = (pow(2, Params.ep - 2)
	- pow(2, Params.ep - Params.eT - 1)
	+ pow(2, Params.eq - Params.ep - 1))
	for deg in h2.max_degree:
		h2.set_coefficient(deg, h2_co)
	Params.h2 = h2
	
	# Initialize h
	var h = PolyMatrix.new(Params.l, 1, Params.n)
	for r in h.rows:
		h.set_value(r, 0, h1)
	Params.h = h
