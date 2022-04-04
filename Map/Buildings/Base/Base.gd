extends Building

var nearOre :=false

func _ready():
	type = 1
	hp = 5000
	hpMax = 5000
	atk = 30
	HPBAR = false
	updatePlacement(null, false)

signal hit
signal GAMEOVER
func hit(_dmg : int) -> void:
	.hit(_dmg)
	emit_signal("hit", hp, hpMax)
	if hp <= 0:
		emit_signal("GAMEOVER")
	pass



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

var ENEMY_TARGET = null
onready var AttackTimer := get_node("AttackTimer")
func _enemyInRange(_body):
	if _body.has_method("__amEnemy") && null==ENEMY_TARGET:
		ENEMY_TARGET = _body
		AttackTimer.start()
	pass


func _enemyOutOfRange(_body):
	if _body == ENEMY_TARGET:
		ENEMY_TARGET = null
	pass

onready var AtkArea = get_node("AttackArea")
func _onAttackTimer():
	if null != ENEMY_TARGET:
		attack(ENEMY_TARGET)
	else:
		var possibleTargets = AtkArea.get_overlapping_bodies()
		for t in possibleTargets:
			if t.has_method("__amEnemy"):
				ENEMY_TARGET=t

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

func _amBase():
	pass
