class_name Fighter2DController

extends CharacterBody2D

@export_category("Refs")
@export var state_machine: Fighter2DStateMachine

@export_category("Settings")
@export var negative_edge = 15
@export_flags("A", "B", "C", "D", "E", "F", "G") var any_attack_mask: int

@export_category("Stats")
@export var max_speed: float = 800.0
@export var min_jump_height = 200.0
@export var max_jump_height = 300.0
@export var jump_distance = 400.0

var _input_buffer_data: Fighter2DInputBuffer.InputBufferData
var _input_hold_data: Fighter2DInputBuffer.InputHoldData



var distance = 0.0
var prev_pos_x = 0.0

@export_range(0.5, 0.9) var rise_dur = 0.5

var air_time = 0.0
var in_air = false
var dropping = false

var jump_force = 0.0
var fall_gravity = 0.0
var near_peak_gravity = 0.0
var rise_gravity = 0.0

var slide_duration: float = 0.5
var slide_cur_duration: float = 0.0

var max_air_actions = 1
var air_actions = 1

@export_category("Stats")
@export var speed: float
@export var speed_curve: Curve
@export var speed_curve_duration: float
@export var axis_scale: float
@export var axis_offset: float
@export var can_jump: bool




var _time: float

# Debug
var _lowest_y_pos = 0
var _highest_y_pos = 0




func set_controller_data(controller_data: Fighter2DControllerData) -> void:
	speed = controller_data.speed
	speed_curve = controller_data.speed_curve
	speed_curve_duration = controller_data.speed_curve_duration
	axis_scale = controller_data.axis_scale
	axis_offset = controller_data.axis_offset
	can_jump = controller_data.can_jump

var _grounded: bool = true

func _ready():
	# Setup inputs
	_input_buffer_data = Fighter2DInputBuffer.InputBufferData.new(any_attack_mask << Fighter2DInputs.INPUT_DIRECTION_COUNT, negative_edge)
	_input_hold_data = Fighter2DInputBuffer.InputHoldData.new(Fighter2DInputs.INPUT_COUNT)
	
	
	
	floor_constant_speed = true
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
#	var h = max_jump_height
#	var th = min_jump_time * 0.5
#	var v = -2 * h / th
#	var g = 2 * h / pow(th, 2)

#	var half_distance = jump_distance * 0.5
#	jump_force = (-2.0 * max_jump_height * max_speed) / (half_distance)
#	gravity = (2.0 * max_jump_height * pow(max_speed, 2.0)) / pow(half_distance, 2.0)
#	jump_force += gravity * 0.5 * (1.0 / 60.0)

	var scale = transform.get_scale()
	
	var scaled_jump_distance = jump_distance# * scale.x
	var scaled_max_jump_height = max_jump_height# * scale.y

	var scaled_rise_distance = scaled_jump_distance * rise_dur
	jump_force = (-2.0 * scaled_max_jump_height * speed) / (scaled_rise_distance)
	
	# calculate t for min height
	rise_gravity = (2.0 * scaled_max_jump_height * pow(speed, 2.0)) / pow(scaled_rise_distance, 2.0)
	
	var scaled_fall_distance = scaled_jump_distance - scaled_rise_distance
	fall_gravity = (2.0 * scaled_max_jump_height * pow(speed, 2.0)) / pow(scaled_fall_distance, 2.0)
	
	# Correction, uncertain why
	jump_force += rise_gravity * 0.5 * (1.0 / 60.0)
	print("Force: ", jump_force, " rise: ", rise_gravity, ", fall: ", fall_gravity)
	
	_lowest_y_pos = position.y
	_highest_y_pos = position.y
		
	#_direction_buffer.resize(input_buffer.buffer_size)
	#_direction_buffer.fill(CharacterNextStateData.ToDirection.Right)

func _process(delta: float) -> void:
	run(delta)

func run(delta: float) -> void:
	
	# Process inputs
	var input_state = Fighter2DInputBuffer.get_input_state()
	Fighter2DInputBuffer.process(input_state, _input_buffer_data, _input_hold_data)
	
	var usec = Time.get_ticks_usec()
	state_machine.run(_input_buffer_data, _input_hold_data)
	
	#var usec = Time.get_ticks_usec()
	#_lowest_y_pos = maxf(_lowest_y_pos, position.y)
	#_highest_y_pos = minf(_highest_y_pos, position.y)
	#
	#var grounded_changed = _grounded != is_on_floor()
	#_grounded = is_on_floor()
	#if !in_air:
		#var direction = Input.get_axis("LEFT", "RIGHT")
		#_move(delta, direction)
		#
	#_jump(delta)
	#move_and_slide()
	#print(Time.get_ticks_usec() - usec)

func _move(delta, direction):
	direction = clamp(axis_offset + (direction * axis_scale), -1.0, 1.0)
	if direction == 0.0: _time = 0
	else: _time += 1
	var normalized_time = _time / speed_curve_duration
	var value = speed_curve.sample(normalized_time)
	velocity.x = value * speed
	

func _jump(delta):
	if !can_jump: return
	if is_on_floor():
		
		if in_air:
			
			print("Fall time: ", air_time, ", jump height: ", abs(_highest_y_pos - _lowest_y_pos), ", distance: ", distance)
			_highest_y_pos = position.y
			in_air = false

		if Input.is_action_just_pressed("A"):
			air_time = 0
			distance = 0.0
			#position.y = min_y_pos - jump_height
			velocity.y = jump_force 
			in_air = true
	else:
		
		
		var fall_velocity = rise_gravity * delta
		var next_velocity_y = velocity.y + fall_velocity
		if next_velocity_y < fall_velocity && Input.is_action_pressed("jump"):
			velocity.y = next_velocity_y
		else:
			velocity.y += fall_gravity * delta
	
		distance += abs(position.x - prev_pos_x)
		
	air_time += 1
	prev_pos_x = position.x
