extends Button

@export var row: int
@export var col: int

func _pressed() -> void:
	# if the space is filled or it's the other player's turn, don't do anything
	if Game.board[row][col] != Game.FilledBy.NoOne or Game.current_turn != Game.Turn.PlayerOne:
		return

	Game.update_space(row, col, Game.FilledBy.PlayerOne)
	# make them all look unclickable
	for slot: Button in get_parent().get_children():
		slot.mouse_default_cursor_shape = Control.CURSOR_ARROW
	if Game.game_winner == Game.WinCondition.StillRunning:
		Game.current_turn = Game.Turn.PlayerTwo
		Game.take_ai_turn()
	
