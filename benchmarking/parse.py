import chess

board = chess.Board()


def fen_after_play_moves(uci_string):
   copyboard = board.copy()
   for move in [chess.Move.from_uci(m) for m in uci_string.split()]:
     copyboard.push(move)
   print(copyboard.fen())
 

