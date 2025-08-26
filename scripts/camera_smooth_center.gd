extends Camera2D

@export var target_arr: Array[Node2D]
@export var debug_target: Node2D
var _debug_target: bool

var prev_position: Vector2
var catchup_time: float = 0.1
var velocity: Vector2

var cur_target_arr: Array[Node2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_targets(target_arr)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("a"):
	#	_switch_target()
	
	var cam_pos = Vector2.ZERO
	for n in cur_target_arr:
		if n == null: continue
		cam_pos += n.transform.origin
		
	cam_pos /= max(cur_target_arr.size(), 1)
	position += (cam_pos - position) * delta * (1.0 / catchup_time)
	
func set_targets(target_arr: Array[Node2D]):
	if target_arr == null || target_arr.size() == 0: 
		print(self.name, ": No valid target array specified. Cannot set camera targets")
		return
	cur_target_arr = target_arr

func _switch_target():
	if _debug_target:
		set_targets(target_arr)
	else:
		set_targets([debug_target])
	_debug_target = !_debug_target
