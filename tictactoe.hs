import Board
import Plays
import Symmetry
import System.Environment
import System.IO.Error
import Data.Maybe as Maybe

getHumanPlay :: IO (Integer, Integer)
getHumanPlay = do  
        putStrLn $ "Please choose your move by inputting a pair, e.g. (1, 1)."
        moveChosen <- getLine
        return (read moveChosen)

humanPlay :: Board -> IO (Integer, Integer)
humanPlay board = do
        verifiedMoveChosen <- getHumanPlay
        if verifiedMoveChosen `elem` (validPlays board) then
                return verifiedMoveChosen
        else humanPlay board

mainLoop :: (Board, Player, Integer) -> IO (Board, Player, Integer) 
mainLoop (board, player, size) = do
	putStrLn ""
	putStrLn $ showBoardState size board
	case winner board size of
		Just Unclaimed -> do
			putStrLn "The game was a draw."
			return (board, player, size)
		Just x -> do
			putStrLn  ("The winner is player "  ++ ((show x) ++ "."))
			return (board, player, size)
		Nothing ->
			if player == Player1 then do
				nextHumanPlay <- (humanPlay board) 
				mainLoop ((advancePlay nextHumanPlay player board), nextPlayer player, size)
			else 
				mainLoop (nextBoard, nextPlayer(player), size)
				where 	nextBoard = mid (nextGameState(player, board, size))
					mid (x, y, z) = y

main = do
    (boardsize:_) <- getArgs
    let board = newBoard (read boardsize)
	let player = Player1
	mainLoop (board, player, (read boardsize))
