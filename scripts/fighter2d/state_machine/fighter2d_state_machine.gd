class_name Fighter2DStateMachine

extends Node

@export_category("Resources")
@export var state_network: Fighter2DStateNetwork

@export_category("Scene references")
@export var animated_sprite: AnimatedSprite2D

@export_category("Settings")
@export var keep_triggers_active_time: int = 0

var _input_sequence_arr: Array[Fighter2DInputCommandSequence]
var _state_arr: Array[Fighter2DState]

var _direction = Fighter2DInputCommand.DIRECTION_ABSOLUTE.LEFT
var _trigger_mask_data: Fighter2DInputCommandSequence.InputSequenceMaskData

var _time: int
var _triggers_active_time: int

var _state_index: int
var _cur_state: Fighter2DState
var _state_switch_data_arr: Array[Fighter2DStateNetwork.SwitchData]
var _previous_state_switch_data: Fighter2DStateNetwork.SwitchData
var _current_state_switch_data:  Fighter2DStateNetwork.SwitchData

var _expire_state_index: int
var _expire_direction: int

@export_category("Debug settings")
@export var _debug_mode: bool = false

func get_speed() -> int:
	return _cur_state.speed

func _ready():
	
	_state_switch_data_arr = state_network.create_state_switch_data_arr()
	_state_arr = state_network.state_arr
	_input_sequence_arr = state_network.input_sequence_arr
	
	_trigger_mask_data = Fighter2DInputCommandSequence.InputSequenceMaskData.new()
	# TODO: Every time the state machine switches states, it needs to redefine which command sequence triggers what state
	
	
	_update_current_state(state_network.start_state_index)
	animated_sprite.flip_h = 1 - (int)(_direction)
		
	
func run(_input_buffer_data, _input_hold_data) -> void:
	_time += 1
	if _cur_state.expire_time > 0 && _time > _cur_state.expire_time:
		_direction = _expire_direction ^ (int)(_current_state_switch_data.flip_direction_on_expire)
		_update_current_state(_expire_state_index)
	
	# Reset sequence mask data
	_triggers_active_time += 1
	if _triggers_active_time >= keep_triggers_active_time:
		_trigger_mask_data.reset()
		_triggers_active_time = 0
	
	# Update mask data
	var new_mask_data = Fighter2DInputCommandSequence.InputSequenceMaskData.new()
	# Process sequences
	for i in _input_sequence_arr.size():
		var input_sequence = _input_sequence_arr[i]
		Fighter2DInputCommandSequence.update_sequence_mask_data(input_sequence, _input_buffer_data, _input_hold_data, _direction, new_mask_data)
	_trigger_mask_data.trigger_mask |= new_mask_data.trigger_mask
	_trigger_mask_data.absolute_direction_mask |= new_mask_data.absolute_direction_mask
	if new_mask_data.trigger_mask > 0: _triggers_active_time = 0


	# Check if cancel window is available
	#if _time < _cur_state.cancel_time_start: return
	#if _cur_state.cancel_time_end >= _cur_state.cancel_time_start && _time > _cur_state.cancel_time_end: return
		
	# Process state switches
	var trigger_state_switch_value = Fighter2DStateNetwork.SwitchData.get_trigger_state_switch_value(_previous_state_switch_data, _current_state_switch_data, _trigger_mask_data, false)
	if trigger_state_switch_value & Fighter2DStateNetwork.SwitchData.IS_VALID_FLAG == Fighter2DStateNetwork.SwitchData.IS_VALID_FLAG:
		var new_direction = (trigger_state_switch_value & Fighter2DStateNetwork.SwitchData.FLIP_DIRECTION_FLAG) >> Fighter2DStateNetwork.SwitchData.FLIP_DIRECTION_ID
		var new_state_index = trigger_state_switch_value >> Fighter2DStateNetwork.SwitchData.STATE_INDEX_MASK_SHIFT
		if _cur_state.options & Fighter2DState.OPTIONS.SWITCH_INPUT_TRIGGER_ON_EXPIRE == Fighter2DState.OPTIONS.SWITCH_INPUT_TRIGGER_ON_EXPIRE:
			_expire_direction = new_direction
			_expire_state_index = new_state_index
		else:
			_direction = new_direction
			_update_current_state(new_state_index)
		#print(BitUtilities.int_to_binary_str(trigger_state_switch_value), ": ", Fighter2DInputCommand.DIRECTION_ABSOLUTE.keys()[_direction], " - ", ResourceUtilities.GetResourceName(state_arr[new_state_index]))
	#elif _cur_state.options & Fighter2DState.OPTIONS.USE_X_AXIS == Fighter2DState.OPTIONS.USE_X_AXIS:
		#var pressed_directions = _input_buffer_data.input_buffers[Fighter2DInputBuffer.INPUT_BUFFER_ID.PRESS] & Fighter2DInputBuffer.DIRECTION_BUFFER_MASK.SECTION_A
		#if pressed_directions > 0:
			#if pressed_directions & Fighter2DInputs.INPUT_FLAG.RIGHT > 0: _direction = 1
			#elif pressed_directions & Fighter2DInputs.INPUT_FLAG.LEFT > 0: _direction = 0
			#_expire_direction = ((_cur_state.options & Fighter2DState.OPTIONS.SWITCH_DIRECTION_ON_DEFAULT_EXPIRE) >> 3) ^ _direction
	animated_sprite.flip_h = 1 - (int)(_direction)

func set_state(state: Fighter2DState) -> void:
	var state_index = _state_arr.find(state)
	if state_index < 0: return
	_update_current_state(state_index)

func _update_current_state(index: int) -> void:
	_previous_state_switch_data = _state_switch_data_arr[_state_index]
	_current_state_switch_data = _state_switch_data_arr[index]
	_cur_state = _state_arr[index]
	
	_state_index = index
	_expire_state_index = _current_state_switch_data.expire_index
	_expire_direction = ((_cur_state.options & Fighter2DState.OPTIONS.SWITCH_DIRECTION_ON_DEFAULT_EXPIRE) >> 3) ^ _direction
	
	animated_sprite.play(_cur_state.animation_name)
	
	_time = 0
	
	print("Switched to state ", _cur_state.animation_name)
