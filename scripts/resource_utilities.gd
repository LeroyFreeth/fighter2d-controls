class_name ResourceUtilities

static func GetResourceName(resource: Resource):
	if resource == null: return "Resource is null"
	var name_arr = resource.resource_path.split("/")
	return name_arr[name_arr.size() - 1].replace(".tres", "")	
