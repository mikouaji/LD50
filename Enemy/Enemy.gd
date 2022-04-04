extends KinematicBody

class_name Enemy

var MAIN_TARGET = Vector3.ZERO
var NAVIGATION : Navigation
const SPEED := 20

enum {SEEK, DESTROY}
var STATE := SEEK

var PAUSED = false

var path : Array = []
var path_node := 0

func init(_nav: Navigation, _target : Vector3):
	NAVIGATION = _nav
	MAIN_TARGET = _target 
	__updatePath()

func _physics_process(_delta):
	if not PAUSED:
		if path_node < path.size():
			var dir = path[path_node] - global_transform.origin
			if dir.length() < 1:
				path_node +=1
				if path.size() > path_node:
					look_at(path[path_node], Vector3.UP)
			else:
				move_and_slide(dir.normalized() * SPEED, Vector3.UP)
				var slideCount = get_slide_count()
				if slideCount:
					for i in slideCount:
						if get_slide_collision(i).collider.has_method("__amBuilding"):
							__updatePath()
		else:
			STATE = DESTROY
	
func __updatePath():
	path = NAVIGATION.get_simple_path(global_transform.origin, MAIN_TARGET)
	path_node = 0

var ATTACK_TARGET
const ATK : int = 35
func _targetInRange(_body):
	if _body.has_method("__amBuilding"):
		ATTACK_TARGET = _body


func _targetOutOfRange(_body):
	if ATTACK_TARGET == _body:
		ATTACK_TARGET = null
		STATE = SEEK
		__updatePath()


func _onAttackTimer():
	if not PAUSED and STATE == DESTROY:
		if null != ATTACK_TARGET:
			ATTACK_TARGET.hit(ATK)
		else:
			__updatePath()
			STATE=SEEK

var HP := 180
signal destroyed
func hit(_dmg : int) -> void:
	HP -= _dmg
	if HP <= 0:
		emit_signal("destroyed", self)

func __amEnemy()->void:
	pass
