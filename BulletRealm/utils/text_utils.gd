class_name TextUtils


## For numbers > 1,000 and < 1,000,000. Credits u/Drillur
static func format_val_medium(_sign: int, value) -> String:
	#value = String(_sign * round(value))
	var text: String = str(_sign * round(value))
	var output := ""
	for i in range(0, text.length()):
		if i != 0 and i % 3 == text.length() % 3:
			output += ","
		output += text[i]
	return output # 342,945
