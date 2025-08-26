class_name BitUtilities

static func highest_bit(n: int) -> int:
	n |= (n >> 1)
	n |= (n >> 2)
	n |= (n >> 4)
	n |= (n >> 8)
	n |= (n >> 16)
	n |= (n >> 32)
	return n - (n >> 1);
	
static func highest_bit_position(n: int) -> int:
	var p = -1
	while n > 0:
		p += 1
		n = n >> 1
	return p

static func int_to_binary_str(n : int, bit_count: int = 64) -> String:
	var str = ""
	for i in bit_count: str += str((n >> (bit_count - (i + 1))) & 1)
	return str
