class_name Fighter2DInputs

# All the inputs the Fighter2D system will support
enum INPUT_ID {
	LEFT = 0, RIGHT = 1, DOWN = 2, UP = 3,
	A = 4, B = 5, C = 6, D = 7, 
	E = 8, F = 9, G = 10, H = 11
}

# When changing inputs, revalidate whether these constants need to be adjusted to match
const INPUT_DIRECTION_COUNT = 4
const INPUT_BUTTON_COUNT = 8
const INPUT_COUNT = INPUT_DIRECTION_COUNT + INPUT_BUTTON_COUNT

# Uses the ID's to setup flags
enum INPUT_FLAG {
	LEFT = 1 << INPUT_ID.LEFT, RIGHT = 1 << INPUT_ID.RIGHT, DOWN = 1 << INPUT_ID.DOWN, UP = 1 << INPUT_ID.UP,
	A = 1 << INPUT_ID.A, B = 1 << INPUT_ID.B, C = 1 << INPUT_ID.C, D = 1 << INPUT_ID.D, 
	E = 1 << INPUT_ID.E, F = 1 << INPUT_ID.F, G = 1 << INPUT_ID.G, H = 1 << INPUT_ID.H,
}

const MAX_INPUT_BUFFER_SIZE = 64 / INPUT_COUNT

enum INPUT_MASK {
	ALL_INPUTS = (1 << INPUT_COUNT) - 1, 
	ALL_DIRECTIONS = (1 << INPUT_DIRECTION_COUNT) - 1,
	ALL_BUTTONS = ((1 << INPUT_BUTTON_COUNT) - 1) << INPUT_DIRECTION_COUNT,
	LEFT_AND_RIGHT = INPUT_FLAG.LEFT | INPUT_FLAG.RIGHT
}

enum DIAGONAL_INPUT_DIRECTION_MASK {
	LEFT_DOWN = INPUT_FLAG.LEFT | INPUT_FLAG.DOWN,
	LEFT_UP = INPUT_FLAG.LEFT | INPUT_FLAG.UP,
	RIGHT_DOWN = INPUT_FLAG.RIGHT | INPUT_FLAG.DOWN,
	RIGHT_UP = INPUT_FLAG.RIGHT | INPUT_FLAG.UP,
}

#
static func debug_input_buffer_to_string(input_state: int, buffer_size: int = MAX_INPUT_BUFFER_SIZE):
	var keys = INPUT_FLAG.keys()
	var values =  INPUT_FLAG.values()
	
	var sections = []
	sections.resize(buffer_size)
	sections.fill("")
		
	# Sections
	for s in buffer_size:
		for i in INPUT_COUNT:
			var value = values[i]	
			if input_state & value != value: continue
			var suffix = ", "
			sections[s] += str(keys[i], suffix)
		var l = sections[s].length() - 2
		if l > 0: sections[s] = sections[s].substr(0, l)
		else: sections[s] = ""
		input_state = input_state >> INPUT_COUNT
	
	sections.reverse()
	
	var section_keys = ["SECTION_F", "SECTION_E", "SECTION_D", "SECTION_C", "SECTION_B" , "SECTION_A"]
	section_keys = section_keys.slice(section_keys.size() - buffer_size, section_keys.size())
	var str = ""
	for s in buffer_size:
		if sections[s].length() > 0: str += str(section_keys[s], ": ", sections[s], ", ")
	var l = str.length() - 2
	if l > 0: str = str.substr(0, l)
	else: str = "No inputs"
	return str
