module Parser where

-- standard
import Control.Monad.Error (liftIO, throwError, fail)
import Control.Monad (replicateM)
-- 3rd party
import Text.ParserCombinators.Parsec (parse, Parser, many,
                                      digit, noneOf, char,
                                      count, eof, (<|>), try)
-- own
import Types (Match, ThrowsError)


readMatch :: String -> ThrowsError Match
readMatch input = case parse parseCsv "csv" input of
  Left err -> throwError $ show err
  Right val -> return val

readMatches :: [String] ->  [Match]
readMatches xs = foldr (\x acc -> case readMatch x of
                                   Left _ -> acc
                                   Right m -> m:acc) [] xs

parseCsv :: Parser Match
parseCsv = do
  date <- parseDate
  homeT <- parseTeam
  awayT <- parseTeam
  (goalsH, goalsA) <- parseGoals
  (odd1x, oddx, oddx2) <- parseOdds
  eof
  return (date, homeT, awayT, goalsH, goalsA, odd1x, oddx, oddx2)

-- Parsers for parseCSV  
parseDate :: Parser Int
parseDate = do
  year <- replicateM 4 digit
  char '.'
  month <- replicateM 2 digit
  char '.'
  day <- replicateM 2 digit
  char ','
  return $ read (year++month++day)

parseTeam :: Parser String
parseTeam = do
  team <- many (noneOf ",")
  char ','
  return team

parseGoals :: Parser (Int, Int)
parseGoals = do
  goalsH <- minusOne <|> many digit
  char ','
  goalsA <- checkField goalsH (many digit)
  char ','
  return (read goalsH :: Int, read goalsA :: Int)

parseOdds :: Parser (Double, Double, Double)
parseOdds = do
  odd1x <- minusOne <|> odds
  char ','
  oddx <- checkField odd1x odds
  char ','
  oddx2 <- checkField oddx odds
  return (read odd1x :: Double,
          read oddx :: Double,
          read oddx2 :: Double)

minusOne :: Parser String
minusOne = do
  sign <- char '-'
  one <- char '1'
  return [sign, one]

odds :: Parser String
odds = do
  int <- many digit
  dot <- char '.'
  rest <- many digit
  return $ int ++ [dot] ++ rest

checkField :: String -> Parser String -> Parser String
checkField field p = if field == "-1"
                     then minusOne
                     else p
