class_name AudioUtils


## Prevents a float value from being converted to '-inf' and clamps
## it to a minimum value of -100.0 (which is effectively "no sound").
static func linear_to_db_min(value: float) -> float:
	return maxf(linear_to_db(value), -100.0)
