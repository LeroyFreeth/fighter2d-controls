class_name Fighter2DInputBuffer

enum INPUT_BUFFER_ID {
	HOLD = 0,
	PRESS = 1,
	RELEASE = 2,
}

enum INPUT_BUFFER_MASK {
	SECTION_A = Fighter2DInputs.INPUT_MASK.ALL_INPUTS,
	SECTION_B = (Fighter2DInputs.INPUT_MASK.ALL_INPUTS << Fighter2DInputs.INPUT_COUNT) & ~Fighter2DInputs.INPUT_MASK.ALL_INPUTS,
	SECTION_C = (Fighter2DInputs.INPUT_MASK.ALL_INPUTS << (Fighter2DInputs.INPUT_COUNT * 2)) & ~(Fighter2DInputs.INPUT_MASK.ALL_INPUTS << Fighter2DInputs.INPUT_COUNT),
	SECTION_D = (Fighter2DInputs.INPUT_MASK.ALL_INPUTS << (Fighter2DInputs.INPUT_COUNT * 3)) & ~(Fighter2DInputs.INPUT_MASK.ALL_INPUTS << Fighter2DInputs.INPUT_COUNT * 2),
	SECTION_E = (Fighter2DInputs.INPUT_MASK.ALL_INPUTS << (Fighter2DInputs.INPUT_COUNT * 4)) & ~(Fighter2DInputs.INPUT_MASK.ALL_INPUTS << Fighter2DInputs.INPUT_COUNT * 3),
	SECTION_F = (Fighter2DInputs.INPUT_MASK.ALL_INPUTS << (Fighter2DInputs.INPUT_COUNT * 5)) & ~(Fighter2DInputs.INPUT_MASK.ALL_INPUTS << Fighter2DInputs.INPUT_COUNT * 4),
}

enum DIRECTION_BUFFER_MASK {
	SECTION_A = Fighter2DInputs.INPUT_MASK.ALL_DIRECTIONS,
	SECTION_B = Fighter2DInputs.INPUT_MASK.ALL_DIRECTIONS << Fighter2DInputs.INPUT_COUNT,
	SECTION_C = Fighter2DInputs.INPUT_MASK.ALL_DIRECTIONS << (Fighter2DInputs.INPUT_COUNT * 2),
	SECTION_D = Fighter2DInputs.INPUT_MASK.ALL_DIRECTIONS << (Fighter2DInputs.INPUT_COUNT * 3),
	SECTION_E = Fighter2DInputs.INPUT_MASK.ALL_DIRECTIONS << (Fighter2DInputs.INPUT_COUNT * 4),
	SECTION_F = Fighter2DInputs.INPUT_MASK.ALL_DIRECTIONS << (Fighter2DInputs.INPUT_COUNT * 5),
}

enum BUTTON_BUFFER_MASK {
	SECTION_A = Fighter2DInputs.INPUT_MASK.ALL_BUTTONS,
	SECTION_B = Fighter2DInputs.INPUT_MASK.ALL_BUTTONS << Fighter2DInputs.INPUT_COUNT,
	SECTION_C = Fighter2DInputs.INPUT_MASK.ALL_BUTTONS << (Fighter2DInputs.INPUT_COUNT * 2),
	SECTION_D = Fighter2DInputs.INPUT_MASK.ALL_BUTTONS << (Fighter2DInputs.INPUT_COUNT * 3),
	SECTION_E = Fighter2DInputs.INPUT_MASK.ALL_BUTTONS << (Fighter2DInputs.INPUT_COUNT * 4),
	SECTION_F = Fighter2DInputs.INPUT_MASK.ALL_BUTTONS << (Fighter2DInputs.INPUT_COUNT * 5),
}

static var keys = Fighter2DInputs.INPUT_FLAG.keys()
static var values = Fighter2DInputs.INPUT_FLAG.values()

class InputBufferData:
	var input_buffers: Array[int]
	var any_attack_mask: int
	var negative_edge: int
	
	func _init(any_attack_mask: int, negative_edge:int):
		input_buffers = []
		input_buffers.resize(INPUT_BUFFER_ID.keys().size())
		input_buffers.fill(0)
		
		self.any_attack_mask = any_attack_mask
		self.negative_edge = negative_edge
		
class InputHoldData: 
	var input_hold_durations_arr: Array[int]
	
	func _init(input_count: int):
		input_hold_durations_arr = []
		input_hold_durations_arr.resize(input_count)
		input_hold_durations_arr.fill(0)
		
	func get_hold_duration(input_state: int) -> int:
		if input_state == 0: return 0
		var lowest_hold_duration = 9999999999
		for i in 64:
			var shift = 1 << i
			if input_state & shift != shift: continue
			lowest_hold_duration = min(lowest_hold_duration, input_hold_durations_arr[i])
		return lowest_hold_duration
			
			

static func get_input_state() -> int:
	var input_state = 0
	for i in range(0, Fighter2DInputs.INPUT_COUNT):
		if Input.is_action_pressed(keys[i]): 
			input_state |= values[i]
	return input_state

static func process(hold_input_state: int, input_buffer_data: InputBufferData, input_hold_data: InputHoldData):
	# Cancel out left and right
	if hold_input_state & Fighter2DInputs.INPUT_MASK.LEFT_AND_RIGHT == Fighter2DInputs.INPUT_MASK.LEFT_AND_RIGHT:
			hold_input_state &= ~Fighter2DInputs.INPUT_MASK.LEFT_AND_RIGHT
	
	# Add the any attack to the hold state
	if input_buffer_data.any_attack_mask & hold_input_state > 0: hold_input_state |= Fighter2DInputs.INPUT_FLAG.H
	
	var input_buffers = input_buffer_data.input_buffers
	var input_hold_durations_arr = input_hold_data.input_hold_durations_arr
		
	# Shift all inputs in input buffer
	for i in input_buffers.size(): input_buffers[i] = input_buffers[i] << Fighter2DInputs.INPUT_COUNT
	
	input_buffers[INPUT_BUFFER_ID.HOLD] |= hold_input_state
	var hold_input_buffer = input_buffers[INPUT_BUFFER_ID.HOLD]
	var press_input_state = ((~hold_input_buffer >> Fighter2DInputs.INPUT_COUNT) & (hold_input_buffer & INPUT_BUFFER_MASK.SECTION_A))
	var release_input_state = ((hold_input_buffer >> Fighter2DInputs.INPUT_COUNT) & (~hold_input_buffer & INPUT_BUFFER_MASK.SECTION_A)) 

	for j in Fighter2DInputs.INPUT_COUNT:
		## When a full diagonal is pressed/release, press/release their respective directions as well
		var input_bit = 1 << j
		if hold_input_state & input_bit == input_bit:
			input_hold_durations_arr[j] += 1
		if press_input_state & input_bit == input_bit:
			input_hold_durations_arr[j] = 1
		if release_input_state & input_bit == input_bit:
			if j >= Fighter2DInputs.INPUT_DIRECTION_COUNT:
				if input_buffer_data.negative_edge > 0 && input_hold_durations_arr[j] >= input_buffer_data.negative_edge: press_input_state |= input_bit
			
	input_buffers[INPUT_BUFFER_ID.PRESS] |= press_input_state
	input_buffers[INPUT_BUFFER_ID.RELEASE] |= release_input_state
	
	#print(Fighter2DInputs.debug_input_buffer_to_string(release_input_state))
