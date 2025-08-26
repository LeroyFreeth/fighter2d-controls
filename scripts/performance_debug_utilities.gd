class_name PerformanceDebugUtilities

static func GetFuncTime(callable: Callable):
	var time = Time.get_ticks_usec()
	callable.call()
	var duration = Time.get_ticks_usec() - time
	print("Duration: ", duration)
