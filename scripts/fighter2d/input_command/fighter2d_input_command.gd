class_name Fighter2DInputCommand

extends Resource

const INPUT_BUFFER_DIRECTIONS_MASK = Fighter2DInputs.INPUT_FLAG.LEFT | Fighter2DInputs.INPUT_FLAG.RIGHT | Fighter2DInputs.INPUT_FLAG.LEFT << Fighter2DInputs.INPUT_COUNT | Fighter2DInputs.INPUT_FLAG.RIGHT << Fighter2DInputs.INPUT_COUNT | Fighter2DInputs.INPUT_FLAG.LEFT << (Fighter2DInputs.INPUT_COUNT * 2) | Fighter2DInputs.INPUT_FLAG.RIGHT << (Fighter2DInputs.INPUT_COUNT * 2) | Fighter2DInputs.INPUT_FLAG.LEFT << (Fighter2DInputs.INPUT_COUNT * 3) | Fighter2DInputs.INPUT_FLAG.RIGHT << (Fighter2DInputs.INPUT_COUNT * 3)

enum DIRECTION_ABSOLUTE {
	LEFT = 0, ## World direction left
	RIGHT = 1, ## World direction right
}

enum DIRECTION_RELATIVE {
	BACKWARD = 0, ## Character relative direction backward
	FORWARD = 1, ## Character relative direction forward
}

enum INPUT_TYPE {
	## Ignore an input
	IGNORE = -1,
	## Press an input
	PRESS = Fighter2DInputBuffer.INPUT_BUFFER_ID.PRESS,
	## Hold an input
	HOLD = Fighter2DInputBuffer.INPUT_BUFFER_ID.HOLD,
	## Release an input
	RELEASE = Fighter2DInputBuffer.INPUT_BUFFER_ID.RELEASE,
	## When this input is held, it will break the command, regardless of the other conditions being met
	BREAK = Fighter2DInputBuffer.INPUT_BUFFER_ID.RELEASE + 1
}

## A command can be part of a sequence of commands. This timer specifies the max time between individual commands within a sequence.
const COMMAND_MAX_TIMER = 15
const COMMAND_TIMER_MASK = (int)(pow(2, (int)(ceil(log(COMMAND_MAX_TIMER) / log (2)))) - 1)

## A command can be part of a sequence of commands. The command in a sequence will also store the initial world direction.
## This allows characters that have switched direction during the command sequence, to still trigger the command in the initial direction
const COMMAND_ABSOLUTE_DIRECTION_ID = COMMAND_TIMER_MASK + 1
const COMMAND_ABSOLUTE_DIRECTION_FLAG = (1 << COMMAND_ABSOLUTE_DIRECTION_ID)

## A command can be part of a sequence of commands. The command in a sequence will also store the relative direction.
## Commands with a absolute direction will also have their mirrored counterparts be resolved simultaneously.
## This is to automatically allow, for example, forward based commands to be executed backwards, if the absolute direction changed during the command sequence.
const COMMAND_RELATIVE_DIRECTION_ID = COMMAND_ABSOLUTE_DIRECTION_ID + 1
const COMMAND_RELATIVE_DIRECTION_FLAG = (1 << COMMAND_RELATIVE_DIRECTION_ID)
const COMMAND_COMMITTED_RELATIVE_DIRECTION_FLAG = (1 << (COMMAND_RELATIVE_DIRECTION_ID + 1))

## A command can be part of a sequence of commands. This section of the command stores the amount of commants that have been processed succesfully.
const COMMAND_VALID_FLAG_SHIFT = COMMAND_RELATIVE_DIRECTION_ID + 3
const COMMAND_VALID_FLAG = (1 << COMMAND_VALID_FLAG_SHIFT)

@export_category("Settings")
@export_range(1, Fighter2DInputs.MAX_INPUT_BUFFER_SIZE) var input_buffer_size: int = 1
@export var min_command_hold_duration = 1
@export_range(0, COMMAND_MAX_TIMER - 1) var next_min_input_command_time = 0
@export_range(0, COMMAND_MAX_TIMER) var next_input_command_time = COMMAND_MAX_TIMER

@export_category("Fighter2DInputs")

@export var forward: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var backward: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var down: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var up: INPUT_TYPE = INPUT_TYPE.IGNORE

@export var a: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var b: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var c: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var d: INPUT_TYPE = INPUT_TYPE.IGNORE

@export var e: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var f: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var g: INPUT_TYPE = INPUT_TYPE.IGNORE
@export var any_attack: INPUT_TYPE = INPUT_TYPE.IGNORE

var required_command_arr: Array[int]

func setup():	
	var commands_arr = []
	commands_arr.resize(4)
	commands_arr.fill(0)
	
	if forward != INPUT_TYPE.IGNORE: commands_arr[forward] |= Fighter2DInputs.INPUT_FLAG.LEFT
	if backward != INPUT_TYPE.IGNORE: commands_arr[backward] |= Fighter2DInputs.INPUT_FLAG.RIGHT
	if down != INPUT_TYPE.IGNORE: commands_arr[down] |= Fighter2DInputs.INPUT_FLAG.DOWN
	if up != INPUT_TYPE.IGNORE: commands_arr[up] |= Fighter2DInputs.INPUT_FLAG.UP
	
	if a != INPUT_TYPE.IGNORE: commands_arr[a] |= Fighter2DInputs.INPUT_FLAG.A
	if b != INPUT_TYPE.IGNORE: commands_arr[b] |= Fighter2DInputs.INPUT_FLAG.B
	if c != INPUT_TYPE.IGNORE: commands_arr[c] |= Fighter2DInputs.INPUT_FLAG.C
	if d != INPUT_TYPE.IGNORE: commands_arr[d] |= Fighter2DInputs.INPUT_FLAG.D
	
	if e != INPUT_TYPE.IGNORE: commands_arr[e] |= Fighter2DInputs.INPUT_FLAG.E
	if f != INPUT_TYPE.IGNORE: commands_arr[f] |= Fighter2DInputs.INPUT_FLAG.F
	if g != INPUT_TYPE.IGNORE: commands_arr[g] |= Fighter2DInputs.INPUT_FLAG.G
	if any_attack != INPUT_TYPE.IGNORE: commands_arr[any_attack] |= Fighter2DInputs.INPUT_FLAG.H
	
	var required_command_left = 0
	for i in commands_arr.size():
		required_command_left |= commands_arr[i] << (Fighter2DInputs.INPUT_COUNT * i)
	
	var direction_inputs = required_command_left & Fighter2DInputCommand.INPUT_BUFFER_DIRECTIONS_MASK
	var required_command_right = (required_command_left & ~Fighter2DInputCommand.INPUT_BUFFER_DIRECTIONS_MASK) | ((direction_inputs >> 1 | direction_inputs << 1) & Fighter2DInputCommand.INPUT_BUFFER_DIRECTIONS_MASK)
	
	required_command_arr = []
	required_command_arr.resize(2)
	required_command_arr.fill(0)
	required_command_arr[0] = required_command_left
	required_command_arr[1] = required_command_right
