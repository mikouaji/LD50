extends Building

func _ready():
	type = 4
	atk = 0
	hp = 750
	hpMax = 750
	initHPBar()

func _buildAreaEntered(_body):
	updatePlacement(_body)

func _buildAreaExited(_body):
	updatePlacement(_body, true)
