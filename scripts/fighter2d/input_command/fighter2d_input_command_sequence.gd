class_name Fighter2DInputCommandSequence

extends Resource

static var section_masks = Fighter2DInputBuffer.INPUT_BUFFER_MASK.values()

@export var input_command_arr: Array[Fighter2DInputCommand]
var command_sequence_state: int
var required_command_sequence_state: int
var index: int = -1

class InputSequenceMaskData:
	var trigger_mask: int
	var absolute_direction_mask: int
	
	func _init() -> void:
		reset()
		
	func reset() -> void:
		trigger_mask = 0
		absolute_direction_mask = 0
		
	func _to_string() -> String:
		return str("Trigger mask:   ", BitUtilities.int_to_binary_str(trigger_mask), "\n", "Direction mask: ", BitUtilities.int_to_binary_str(absolute_direction_mask))

func setup(index: int):
	self.index = index
	required_command_sequence_state = (input_command_arr.size() - 1) << Fighter2DInputCommand.COMMAND_VALID_FLAG_SHIFT
	for input_command in input_command_arr:
		input_command.setup()
	
	print(ResourceUtilities.GetResourceName(self), " setup for index ", index)

static func update_sequence_mask_data(input_sequence: Fighter2DInputCommandSequence, input_buffer_data: Fighter2DInputBuffer.InputBufferData, input_hold_data: Fighter2DInputBuffer.InputHoldData, direction: Fighter2DInputCommand.DIRECTION_ABSOLUTE, sequence_mask_data: InputSequenceMaskData) -> void:
	var input_buffers = input_buffer_data.input_buffers
	
	var is_valid = true
	var command_index = (input_sequence.command_sequence_state & ~Fighter2DInputCommand.COMMAND_ABSOLUTE_DIRECTION_FLAG) >> Fighter2DInputCommand.COMMAND_VALID_FLAG_SHIFT
	var input_command = input_sequence.input_command_arr[command_index]
	
	var sequence_direction = direction
	
	# TODO: Add min command time
	var command_time = input_sequence.command_sequence_state & Fighter2DInputCommand.COMMAND_TIMER_MASK
	# Update input command and direction
	if command_time == 0: 
		input_sequence.command_sequence_state = direction * Fighter2DInputCommand.COMMAND_ABSOLUTE_DIRECTION_FLAG
	else: 
		input_sequence.command_sequence_state -= 1
		sequence_direction = (input_sequence.command_sequence_state & Fighter2DInputCommand.COMMAND_ABSOLUTE_DIRECTION_FLAG) >> Fighter2DInputCommand.COMMAND_ABSOLUTE_DIRECTION_ID
	
	var input_state = 0
	for i in input_buffers.size():
		for j in input_command.input_buffer_size: 
			var inputs = (input_buffers[i] >> (j * Fighter2DInputs.INPUT_COUNT)) & Fighter2DInputBuffer.INPUT_BUFFER_MASK.SECTION_A
			if inputs == 0: continue
			input_state |= inputs << (i * Fighter2DInputs.INPUT_COUNT)
	
	var required_command_arr = [input_command.required_command_arr[sequence_direction], input_command.required_command_arr[1 - sequence_direction]]
	var can_reverse = required_command_arr[0] != required_command_arr[1]

	var relative_direction = (input_sequence.command_sequence_state & Fighter2DInputCommand.COMMAND_RELATIVE_DIRECTION_FLAG) >> Fighter2DInputCommand.COMMAND_RELATIVE_DIRECTION_ID
	var commited_relative_flag = input_sequence.command_sequence_state & Fighter2DInputCommand.COMMAND_COMMITTED_RELATIVE_DIRECTION_FLAG
	
	for i in 2:
		var required_input_command = required_command_arr[i]
		if commited_relative_flag > 0:
			if i != relative_direction: continue
			var breaks = (required_input_command & Fighter2DInputBuffer.INPUT_BUFFER_MASK.SECTION_D) >> ((Fighter2DInputCommand.INPUT_TYPE.BREAK - Fighter2DInputCommand.INPUT_TYPE.HOLD) * Fighter2DInputs.INPUT_COUNT)
			if breaks & input_state > 0:
				input_sequence.command_sequence_state = 0
				return
	
		# Remove break section
		required_input_command &= ~Fighter2DInputBuffer.INPUT_BUFFER_MASK.SECTION_D
		
		var sequence_shift = input_sequence.index
		if input_state & required_input_command == required_input_command:
			if input_command.min_command_hold_duration > 1:
				var hold_duration = input_hold_data.get_hold_duration(required_input_command & Fighter2DInputBuffer.INPUT_BUFFER_MASK.SECTION_A)
				if hold_duration < input_command.min_command_hold_duration: return
			if input_sequence.required_command_sequence_state & input_sequence.command_sequence_state == input_sequence.required_command_sequence_state:
				if can_reverse:
					var absolute_direction = sequence_direction >> Fighter2DInputCommand.COMMAND_ABSOLUTE_DIRECTION_FLAG
					#print("Executed ", ResourceUtilities.GetResourceName(input_sequence), " ", Fighter2DInputCommand.DIRECTION_ABSOLUTE.keys()[absolute_direction])
					sequence_shift += i
					sequence_mask_data.trigger_mask |= 1 << (sequence_shift)
					sequence_mask_data.absolute_direction_mask |= absolute_direction << (sequence_shift)
					# When sequence direction isn't equal to current direction, also include the turned around version of the sequence
					if absolute_direction ^ direction:
						sequence_shift -= i + (1 - i)
						sequence_mask_data.trigger_mask |= 1 << sequence_shift 
						sequence_mask_data.absolute_direction_mask |= direction << sequence_shift
				else:
					sequence_mask_data.trigger_mask |= 1 << sequence_shift
					sequence_mask_data.absolute_direction_mask |= direction << sequence_shift
					
			else:
				# Update time
				input_sequence.command_sequence_state |= input_command.next_input_command_time
				input_sequence.command_sequence_state += Fighter2DInputCommand.COMMAND_VALID_FLAG
				
				# Set the relative flag
				if !commited_relative_flag: input_sequence.command_sequence_state |= Fighter2DInputCommand.COMMAND_RELATIVE_DIRECTION_FLAG * i
				input_sequence.command_sequence_state |= Fighter2DInputCommand.COMMAND_COMMITTED_RELATIVE_DIRECTION_FLAG * (int)(can_reverse)
		if !can_reverse: return
	return
