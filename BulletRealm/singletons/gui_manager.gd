extends Node
## GUIManager : Singleton that hosts signals for updating user-facing GUI
## components on the client app.


## Show the status panel if it is currently hidden. Otherwise, hide it.
signal toggle_player_status_panel_visibility
## Signal for Health, Mana, Experience, etc. Doesn't need to be constantly updated,
## as it can result in jittery text in the UI.
signal on_player_attributes_updated(attrs: Attributes)
signal on_player_status_effects_updated(status: StatusEffects)


func is_player_status_panel_showing():
	# This might be an expensive operation to traverse the scene tree.
	# Can revisit this later.
	pass
