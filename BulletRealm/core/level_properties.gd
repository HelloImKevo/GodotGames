class_name LevelProperties


## Starting HP for this unit.
var start_hp: float
## Default is 1 HP per point of Vitality, per level. This scale factor
## can be increased or decreased to cause big fluctuations in unit HP.
var hp_per_level_factor: int
## Vitality affects HP gained per level.
var start_vitality: float
## Vitality gained per level.
var vitality_per_level: int


func _init(s_hp: float,
		hp_plf: int,
		s_vit: float,
		v_pl: int):
	start_hp = s_hp
	hp_per_level_factor = hp_plf
	start_vitality = s_vit
	vitality_per_level = v_pl


# TODO: Work in progress. This construct should be Attribtues driven.
func get_max_hp() -> float:
	return 0.0
