extends Node


enum Turn {
	PlayerOne,
	PlayerTwo
}

# board spaces enum
enum FilledBy {
	NoOne,
	PlayerOne,
	PlayerTwo
}

enum WinCondition {
	StillRunning,
	Tie,
	PlayerOneWins,
	PlayerTwoWins
}

var board = [
	[FilledBy.NoOne, FilledBy.NoOne, FilledBy.NoOne],
	[FilledBy.NoOne, FilledBy.NoOne, FilledBy.NoOne],
	[FilledBy.NoOne, FilledBy.NoOne, FilledBy.NoOne],
]

var game_winner = WinCondition.StillRunning

var button_grid: GridContainer = null
var win_label: Label = null

var first_turn := Turn.PlayerOne
var current_turn: Turn

var text_legend = {
	FilledBy.NoOne: "",
	FilledBy.PlayerOne: "X",
	FilledBy.PlayerTwo: "O"
}

func reset_game():
	current_turn = first_turn
	for slot: Button in button_grid.get_children():
		slot.text = ""
	
	board = [
		[FilledBy.NoOne, FilledBy.NoOne, FilledBy.NoOne],
		[FilledBy.NoOne, FilledBy.NoOne, FilledBy.NoOne],
		[FilledBy.NoOne, FilledBy.NoOne, FilledBy.NoOne],
	]
	
	win_label.hide()
	button_grid.show()
	
	game_winner = WinCondition.StillRunning

func update_space(row: int, col: int, filled_by: FilledBy = FilledBy.NoOne):
	board[row][col] = filled_by
	if button_grid:
		button_grid.get_child(3 * row + col).text = text_legend[filled_by]
	
	game_winner = check_win_condition()
	if game_winner == WinCondition.StillRunning:
		return
	match game_winner:
		WinCondition.Tie:
			win_label.text = "It's a tie!"
		WinCondition.PlayerOneWins:
			win_label.text = text_legend[FilledBy.PlayerOne] + " wins!"
		WinCondition.PlayerTwoWins:
			win_label.text = text_legend[FilledBy.PlayerTwo] + " wins!"

	button_grid.hide()
	win_label.show()
	get_tree().create_timer(3).timeout.connect(reset_game)

func check_win_condition() -> WinCondition:
	# check all rows for winning/blocking move
	for row_num in range(3):
		var row: Array = board[row_num]
		if row.count(FilledBy.PlayerOne) == 3:
			print("p1 by row")
			return WinCondition.PlayerOneWins
		elif row.count(FilledBy.PlayerTwo) == 3:
			print("p2 by row")
			return WinCondition.PlayerTwoWins

	# flip the board
	var cols = [
		[board[0][0], board[1][0], board[2][0]],
		[board[0][1], board[1][1], board[2][1]],
		[board[0][2], board[1][2], board[2][2]],
	]
	# check all columns for winning/blocking move
	for col_num in range(3):
		var col: Array = cols[col_num]
		if col.count(FilledBy.PlayerOne) == 3:
			print("p1 by col")
			return WinCondition.PlayerOneWins
			print("the fuck??")
		elif col.count(FilledBy.PlayerTwo) == 3:
			print("p2 by col")
			return WinCondition.PlayerTwoWins

	# create the diagonals
	var left_diag = [board[0][0], board[1][1], board[2][2]]
	var right_diag = [board[0][2], board[1][1], board[2][0]]
	
	# check the diagonals
	if left_diag.count(FilledBy.PlayerOne) == 3 or right_diag.count(FilledBy.PlayerOne) == 3:
		print("p1 by diag")
		return WinCondition.PlayerOneWins
	elif left_diag.count(FilledBy.PlayerTwo) == 3 or right_diag.count(FilledBy.PlayerTwo) == 3:
		print("p2 by diag")
		return WinCondition.PlayerTwoWins
	
	var tied = true
	for row in board:
		for col in row:
			if col == FilledBy.NoOne:
				tied = false
	if tied:
		return WinCondition.Tie
	
	return WinCondition.StillRunning

func get_possible_moves() -> Array:
	var possibles = []
	for row_num in range(3):
		for col_num in range(3):
			if board[row_num][col_num] == FilledBy.NoOne:
				possibles.append({"row": row_num, "col": col_num})
	return possibles

func decide_move():
	# check all rows for winning/blocking move
	for row_num in range(3):
		var row: Array = board[row_num]
		# winning move
		if (row.count(FilledBy.PlayerTwo) == 2 or row.count(FilledBy.PlayerOne) == 2) and row.count(FilledBy.NoOne) == 1:
			return {"row": row_num, "col": row.find(FilledBy.NoOne)}

	# flip the board
	var cols = [
		[board[0][0], board[1][0], board[2][0]],
		[board[0][1], board[1][1], board[2][1]],
		[board[0][2], board[1][2], board[2][2]],
	]
	# check all columns for winning/blocking move
	for col_num in range(3):
		var col: Array = cols[col_num]
		if (col.count(FilledBy.PlayerTwo) == 2 or col.count(FilledBy.PlayerOne) == 2) and col.count(FilledBy.NoOne) == 1:
			return {"col": col_num, "row": col.find(FilledBy.NoOne)}

	# create the diagonals
	var left_diag = [board[0][0], board[1][1], board[2][2]]
	var right_diag = [board[0][2], board[1][1], board[2][0]]
	
	# check the diagonals
	if (left_diag.count(FilledBy.PlayerTwo) == 2 or left_diag.count(FilledBy.PlayerOne) == 2) and left_diag.count(FilledBy.NoOne) == 1:
		var n = left_diag.find(FilledBy.NoOne)
		return {"col": n, "row": n}
	# check the diagonals
	if (right_diag.count(FilledBy.PlayerTwo) == 2 or right_diag.count(FilledBy.PlayerOne) == 2) and right_diag.count(FilledBy.NoOne) == 1:
		var n = right_diag.find(FilledBy.NoOne)
		match n:
			0: return {"col": 2, "row": 0}
			1: return {"col": 1, "row": 1}
			2: return {"col": 0, "row": 2}

	# if none of those resolved, pick a random possible move
	var moves = get_possible_moves()
	if moves.size() > 0:
		return moves.pick_random()
	else:
		return {}
	
func take_ai_turn():
	var move = decide_move()
	
	if move:
		update_space(move["row"], move["col"], FilledBy.PlayerTwo)

	# make it the player's turn
	current_turn = Turn.PlayerOne
	if button_grid:
		for slot: Button in button_grid.get_children():
			slot.mouse_default_cursor_shape = slot.CURSOR_POINTING_HAND
			#print(slot.get_cursor_shape())
			#print(slot.CURSOR_POINTING_HAND)
