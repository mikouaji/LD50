extends Building

func _ready():
	type = 3
	hp = 500
	hpMax = 500
	atk = 15
	initHPBar()


func _buildAreaEntered(_body):
	updatePlacement(_body)


func _buildAreaExited(_body):
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
	if null != ENEMY_TARGET and placed:
		attack(ENEMY_TARGET)
	else:
		var possibleTargets = AtkArea.get_overlapping_bodies()
		for t in possibleTargets:
			if t.has_method("__amEnemy"):
				ENEMY_TARGET=t
