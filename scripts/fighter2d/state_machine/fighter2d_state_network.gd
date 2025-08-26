class_name Fighter2DStateNetwork

extends Resource

@export var state_arr: Array[Fighter2DState]
# TODO: Sequences can share input commands
@export var input_sequence_arr: Array[Fighter2DInputCommandSequence]
@export var switch_arr: Array[Fighter2DSwitchConditions]

@export var start_state_index: int = 0
@export var expire_state_index: int = 0
@export var flip_direction_on_expire: bool = false
@export var get_hit_ground_index: int = -1
@export var get_hit_air_index: int = -1
@export var get_hit_knockdown_index: int = -1
@export var get_hit_launched_index: int = -1

class SwitchData:
		# Binary layout "trigger_state_switch_value_arr":
	# |62---------------|61-----------------|60-----------|...|57-----------|57---------|...|00---------|
	# |REQUIRES_HIT_FLAG|FLIP_DIRECTION_FLAG|BUFFER_WINDOW|...|BUFFER_WINDOW|STATE_INDEX|...|STATE_INDEX|
	# |-----------------|-------------------|-------------|...|-------------|-----------|...|-----------|

	const IS_VALID_ID = 0
	const IS_VALID_FLAG = 1 << IS_VALID_ID

	const FLIP_DIRECTION_ID = IS_VALID_ID + 1
	const FLIP_DIRECTION_FLAG = 1 << FLIP_DIRECTION_ID

	const REQUIRES_HIT_ID = FLIP_DIRECTION_ID + 1
	const REQUIRES_HIT_FLAG = 1 < REQUIRES_HIT_ID

	const STATE_INDEX_MASK_SHIFT = REQUIRES_HIT_ID + 1
	const STATE_INDEX_MASK = ~((1 << STATE_INDEX_MASK_SHIFT) - 1)
	
	var trigger_mask: int
	var hit_trigger_mask: int
	
	#var input_buffer_trigger_mask_arr: Array[int]	
	# An array of switch masks for every possible buffered input frame
	var trigger_state_switch_value_arr: Array[int]
	
	var expire_index: int
	var flip_direction_on_expire: bool
	
	func _init(switch_arr: Array[Fighter2DStateSwitchInputTrigger], state_arr: Array[Fighter2DState], sequence_arr: Array[Fighter2DInputCommandSequence], input_sequence_size: int,
		expire_index: int, flip_direction_on_expire: bool):
		# Just ensurance
		trigger_mask = 0
		
		trigger_state_switch_value_arr = []
		trigger_state_switch_value_arr.resize(input_sequence_size)
		trigger_state_switch_value_arr.fill(0)
		
		for switch in switch_arr:
			var index = switch.input_command_sequence.index
			if index < 0: continue
			
			print(ResourceUtilities.GetResourceName(switch.input_command_sequence), ": ", index)
			var state_switch_value = switch.state_index
			if state_switch_value < 0: continue
			
			state_switch_value = state_switch_value << STATE_INDEX_MASK_SHIFT
			state_switch_value |= IS_VALID_FLAG
			state_switch_value |= ((int)(switch.flip_direction) << FLIP_DIRECTION_ID)
			
			index += (int)(switch.reverse_input_command)
			
			trigger_state_switch_value_arr[index] = state_switch_value
			
			var flag = 1 << index
			trigger_mask |= flag
			hit_trigger_mask |= flag * (int)(switch.requires_hit)
			
			
		#print(ResourceUtilities.GetResourceName(state), " switch mask: ", BitUtilities.int_to_binary_str(trigger_mask, 8))
		for i in trigger_state_switch_value_arr:
			print(BitUtilities.int_to_binary_str(i & STATE_INDEX_MASK))
			
		self.expire_index = expire_index
		self.flip_direction_on_expire = flip_direction_on_expire

	static func get_trigger_state_switch_value(prev: SwitchData, cur: SwitchData, mask_data: Fighter2DInputCommandSequence.InputSequenceMaskData, hit: bool):
		var switch_trigger_mask = cur.trigger_mask if !hit else cur.hit_trigger_mask
		switch_trigger_mask &= mask_data.trigger_mask
		if switch_trigger_mask == 0: return 0
		var sequence_index = BitUtilities.highest_bit_position(switch_trigger_mask)
		var switch_state_value = cur.trigger_state_switch_value_arr[sequence_index]
		var state_index = switch_state_value >> STATE_INDEX_MASK_SHIFT
		# TODO: Maybe not pack this as tightly for some readability for external classes
		var state_direction = (mask_data.absolute_direction_mask >> sequence_index & 1) ^ ((switch_state_value & Fighter2DStateNetwork.SwitchData.FLIP_DIRECTION_FLAG) >> Fighter2DStateNetwork.SwitchData.FLIP_DIRECTION_ID)
		return (switch_state_value & ~Fighter2DStateNetwork.SwitchData.FLIP_DIRECTION_FLAG) | (state_direction << Fighter2DStateNetwork.SwitchData.FLIP_DIRECTION_ID)


func create_state_switch_data_arr():
	var l = input_sequence_arr.size()
	var index = 0
	for i in l:
		var sequence = input_sequence_arr[i]
		sequence.setup(index)
		var found_direction_command = false
		for input_command in sequence.input_command_arr:
			found_direction_command = input_command.required_command_arr[0] != input_command.required_command_arr[1]
			if found_direction_command: break
		#print(ResourceUtilities.GetResourceName(sequence), " has left/right: ", found_direction_command, " - provided index: ", index)
		# Each reversed input command has its own index, directly after the non-reversed input command
		index += (1 + (int)(found_direction_command))
	var input_sequence_size = index

	l = min(state_arr.size(), switch_arr.size())
	var switch_data_arr: Array[Fighter2DStateNetwork.SwitchData] = []
	switch_data_arr.resize(l)
	
	for i in l: 
		var expire_index = switch_arr[i].override_expire_state_index if switch_arr[i].override_expire_state_index >= 0 else expire_state_index
		var flip_on_expire = switch_arr[i].override_flip_direction
		#var expire_index = switch_arr[i].override_expire_state_index if switch_arr[i].flip_direction_on_expire  else flip_direction_on_expire
		switch_data_arr[i] = Fighter2DStateNetwork.SwitchData.new(switch_arr[i].arr, state_arr, input_sequence_arr, input_sequence_size, 
		expire_index, flip_on_expire)
	return switch_data_arr
