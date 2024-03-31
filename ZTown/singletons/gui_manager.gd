extends Node
## GUIManager : Singleton that hosts signals for updating user-facing GUI
## components on the client app.


## Show the status panel if it is currently hidden. Otherwise, hide it.
signal toggle_player_status_panel_visibility

## Cycle to the next primary tool, and make it the active one.
## player_number: 1-based index. 1 refers to the only player in singleplayer mode.
signal cycle_next_tool(__player_number: int)

## Signal for Health, Mana, Experience, etc. Doesn't need to be constantly updated,
## as it can result in jittery text in the UI.
signal on_player_attributes_updated(attrs: Attributes)
signal on_player_status_effects_updated(status: StatusEffects)


func is_player_status_panel_showing():
	# This might be an expensive operation to traverse the scene tree.
	# Can revisit this later.
	pass
