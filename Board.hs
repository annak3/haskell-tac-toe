module Board where

import Data.Array as Array
import Data.List as List
import Data.Maybe as Maybe
import Data.Map as Map
import System.Random as Random

data Player = Unclaimed | Player1 | Player2 deriving (Eq, Ord)
data Board = Board (Array (Integer, Integer) Player) Integer deriving (Eq, Ord)

instance Show Board where
  show (Board board limit) =
		List.intercalate separator [ showBoardRow x (Board board limit) | x <- [1..limit ] ]
			where separator = "\n" ++ replicate (fromInteger (limit + limit - 1)) '-' ++ "\n"

instance Show Player where 
	show Unclaimed = " "
	show Player1 = "X"
	show Player2 = "O"

newBoard :: Integer -> Board
newBoard x =
		Board (Array.array ((1,1), (x,x)) [ ((p, y), Unclaimed ) | p <- [1..x], y <- [1..x] ]) x

showBoardRow :: Integer -> Board -> String
showBoardRow row (Board board limit) =
		List.intercalate "|" [ show (board Array.! (row, column) ) | column <- [1..limit] ]

noMoreMoves :: Board -> Bool
noMoreMoves (Board board _) =
	Unclaimed `notElem` Array.elems board
			
isWinningSet :: Board -> [(Integer, Integer)] -> Bool
isWinningSet _ [] = False
isWinningSet (Board _ 1) points = True
isWinningSet (Board _ limit) points 
	| toInteger (length points) < limit = False
	| otherwise = 
		or rows || or columns || (toInteger (length ldiags) >= limit) || (toInteger (length rdiags) >= limit)
		where 	rows = [ toInteger (length (List.filter ( == p) $ fst $ unzip points)) >= limit | p <- [1..limit] ]
			columns = [ toInteger (length (List.filter ( == p) $ snd $ unzip points)) >= limit | p <- [1..limit] ]
			ldiags = [ (x,y) | (x, y) <- points, x == y ]
			rdiags = [ (x, y) | (x, y) <- points, x == limit - y + 1 ]

getPlayerMoves :: Player -> Board -> [(Integer, Integer)]
getPlayerMoves player (Board board _) =
	fst $ unzip $ List.filter (\ pair -> snd pair == player) (Array.assocs board)
	
winner :: Board -> Maybe Player
winner board
	| isWinningSet board (getPlayerMoves Player1 board) = Just Player1
	| isWinningSet board (getPlayerMoves Player2 board) = Just Player2
	| noMoreMoves board = Just Unclaimed
	| otherwise = Nothing

score :: Board -> Maybe Integer
score board =
	case winner board of
		Just Player1 -> Just 1
		Just Player2 -> Just (-1)
		Just Unclaimed -> Just 0
		Nothing -> Nothing

gameOver :: Board -> Bool
gameOver board = 
	isJust (winner board)

