extends Area

var amount : int = 1000
var amountMax : int = 1000
var distanceToCenter : float = 0

const AMOUNT_TO_MINE = 50

onready var Bar3d = get_node("Amount")
onready var Bar3dViewport = get_node("Amount/Viewport")
func _ready():
	Bar3d.texture = Bar3dViewport.get_texture()
	updateBar()
	pass

func init(_amount : int, _dist : float):
	amount = _amount
	amountMax = _amount
	distanceToCenter = _dist
	scale *= (amount/1000)
	pass

signal oreMined
func mine():
	var a = AMOUNT_TO_MINE if amount > AMOUNT_TO_MINE else amount
	emit_signal("oreMined", self, a)
	amount -=a
	updateBar()
	
onready var Bar2d = get_node("Amount/Viewport/ProgressBar")
func updateBar():
	Bar2d.max_value = amountMax
	Bar2d.value = amount

func __amOre():
	pass
