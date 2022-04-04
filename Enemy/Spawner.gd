extends Area

var RNG : RandomNumberGenerator
var MAP : Navigation
var TARGET_POSITION : Vector3
var wave := 1

var enemies := []
var queue := []

onready var SpawnTimer := get_node("Timer")
func init(_rng : RandomNumberGenerator, _startAfter : float, _map : Navigation) -> void:
	RNG = _rng
	MAP = _map
	for b in MAP.buildings:
		if b.has_method("_amBase"):
			TARGET_POSITION = b.global_transform.origin
	print(TARGET_POSITION)
	SpawnTimer.start(_startAfter)


onready var EnemyScene := preload("res://Enemy/Enemy.tscn")
const SPAWN_TIME := Vector2(15, 30)
const SPAWN_AMOUNT := Vector2(2,3)
func _spawn():
	if queue.size() == 0:
		var amount = wave * RNG.randi_range(SPAWN_AMOUNT.x, SPAWN_AMOUNT.y)
		var wait_time = RNG.randf_range(SPAWN_TIME.x, SPAWN_TIME.y)
		for i in amount:
			var enemy = EnemyScene.instance()
			queue.append(enemy)
#		print("WAVE: ",wave, " amont: ", amount, "wait:",wait_time)
		SpawnTimer.wait_time = wait_time
		wave +=1
#		SpawnTimer.stop()

signal SpawningEnemies
signal DestroyedEnemy
func _release():
	if queue.size():
		var spawnPosition = get_translation()+(Vector3.UP*10)
		var enemy = queue.pop_back()
		enemy.set_translation(spawnPosition)
		emit_signal("SpawningEnemies", enemy)
		enemy.init(MAP, TARGET_POSITION)
		enemies.append(enemy)
		enemy.connect("destroyed", self, "_remove")
	pass

func _remove(_enemy)->void:
	enemies.remove(enemies.find(_enemy))
	emit_signal("DestroyedEnemy", _enemy)
