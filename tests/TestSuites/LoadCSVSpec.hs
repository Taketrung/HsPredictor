module TestSuites.LoadCSVSpec (spec) where

--standard

--3rd party
import Test.Hspec.Contrib.HUnit(fromHUnitTest)
import Test.HUnit
--own
import HsPredictor.LoadCSV
import HsPredictor.Queries
import HsPredictor.Types
import HelperFuncs (removeIfExists)


spec = fromHUnitTest $ TestList [
  TestLabel ">>stats" test_stats,
  TestLabel ">>teams"  test_teams,
  TestLabel ">>resultsUpcoming"  test_resultsUpcoming,
  TestLabel ">>resultsAll"  test_resultsAll,
  TestLabel ">>reloadCSV" test_reloadCSV,
  TestLabel ">>getFileContents" test_getFileContents
  ]
                
testFilePath = "tests/tmp/test.csv"
testDbPath = "tests/tmp/test.db"

setUp = do
  removeIfExists testDbPath
  loadCSV testFilePath testDbPath
  
test_stats = TestCase $ do
  setUp
  teams <- getTeams testDbPath
  s1 <- filterStats "A" teams
  s2 <- filterStats "B" teams
  assertEqual "A stats" s1 [4,2,0]
  assertEqual "B stats" s2 [0,2,4]
  where
    filterStats t teams = flip getStats testDbPath
                          ((filter (\x -> x==t) teams)!!0)

test_teams = TestCase $ do
  setUp
  teams <- getTeams testDbPath
  (length teams) @?= 4

test_resultsAll = TestCase $ do
  setUp
  r <- getResultsAll testDbPath
  (length r) @?= 14

test_resultsUpcoming = TestCase $ do
  setUp
  r <- getResultsUpcoming testDbPath
  (length r) @?= 2
  
test_reloadCSV = TestCase $ do
  setUp
  r <- getResultsAll testDbPath
  assertEqual "results all length" (length r) (14)
  loadCSV testFilePath testDbPath -- load again
  r1 <- getResultsAll testDbPath
  (length r1) @?= 14
  assertEqual "results before and after" r r1

test_getFileContents = TestCase $ do
  c <- getFileContents testFilePath
  assertBool "getFileContents" ("" /= c)
