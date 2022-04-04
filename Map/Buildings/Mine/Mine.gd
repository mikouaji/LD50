extends Building

var nearOre :=false

func _ready():
	type = 2
	hp = 350
	hpMax = 350
	atk = 0
	initHPBar()
	updatePlacement(null, false)



onready var OreScript := preload("res://Map/Env/Ore/Ore.gd")
func _checkIfOreEntered(_area):
	if _area.get_script() == OreScript:
		nearOre =true
		updatePlacement(_area, true)
	
func _checkIfOreExited(_area):
	if _area.get_script() == OreScript:
		nearOre =false
		updatePlacement(_area)

func _buildAreaEntered(_body):
	updatePlacement(_body)


func _buildAreaExited(_body):
	if nearOre:
		updatePlacement(_body, true)


onready var MiningTimer = get_node("MiningTimer")
func startMining():
	MiningTimer.start()
		
onready var MineArea = get_node("BuildArea")
func _mineOre():
	var veins = MineArea.get_overlapping_areas()
	for v in veins:
		if v.has_method("__amOre"):
			v.mine()
	pass
