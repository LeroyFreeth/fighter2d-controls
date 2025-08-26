class_name Fighter2DState

extends Resource


@export_category("Switch states")
# These need to align with the input_sequences, so they are a fixed size, per character at the very least
@export var cancel_time_start: int = 0
## When state_switch_triggers stop start triggering state switches
@export var cancel_time_end: int = -1

@export_category("Expire state")
## Duration in frames when the state expires and changes to expire state
@export var expire_time: int

@export_category("Animations")
@export var animation_name: String = "Insert name here"

@export_category("Settings")
@export var controller_data: Fighter2DControllerData

@export var speed = 0
enum OPTIONS {
	ENABLE_X_AXIS = 1 << 0,
	ENABLE_JUMP = 1 << 1,
	RESET_TRIGGERS_ON_ENTER = 1 << 2,
	SWITCH_INPUT_TRIGGER_ON_EXPIRE = 1 << 3,
	SWITCH_DIRECTION_ON_DEFAULT_EXPIRE = 1 << 4,
}
@export_flags(
	"Enable X axis",
	"Enable jump",
 	"Reset triggers on enter",
	"Switch input trigger on expire",
	"Switch direction on default expire",
) var options: int



## TODO: FAT struct
#static func add_switch_states(state_arr: Array[Fighter2DState]):
	#for state in state_arr:
		#for i in state.switch_input_trigger_arr:
			#if state_arr.has(i.state): continue
			#state_arr.push_back(i.state)
#
#
#static func create_state_arr(state: Fighter2DState) -> Array[Fighter2DState]:
	## Create array with all states connected to this one
	#var state_arr: Array[Fighter2DState] = [state]
	#var cur_state_index = 0
	#while cur_state_index < state_arr.size():
		#var cur_state = state_arr[cur_state_index]
		#for switch_input_trigger in cur_state.switch_input_trigger_arr:
			#var switch_state = switch_input_trigger.state
			#if state_arr.has(switch_input_trigger.state): continue
			#state_arr.push_back(switch_state)
		#cur_state_index += 1
	#return state_arr
	
#static func create_state_switch_data_arr(state_arr: Array[Fighter2DState], input_sequence_arr: Fighter2DInputCommandSequenceArr) -> Array[Fighter2DState.SwitchData]:
	#var l = state_arr.size()
	#var switch_SwitchData_arr: Array[Fighter2DState.SwitchData] = []
	#switch_SwitchData_arr.resize(l)
	#for i in l:
		#var state = state_arr[i]
		#switch_SwitchData_arr[i] = Fighter2DState.SwitchData.new(state, state_arr, input_sequence_arr)
	#return switch_SwitchData_arr
