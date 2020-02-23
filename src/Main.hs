import Data.Char          (isSpace)
import Data.List          (dropWhileEnd)
import System.Environment

conversionMap :: [(String, String)]
conversionMap
  = [ ("\\A", "\\forall")
    , ("forall", "\\forall")
    , ("\\E", "\\exists")
    , ("exists", "\\exists")
    , ("in",  "\\in")
    , ("and", "\\land")
    , ("&&", "\\land")
    , ("or", "\\lor")
    , ("||", "\\lor")
    , ("not", "\\neg")
    , ("=>", " \\implies")
    , ("<=>", "\\iff")
    , ("/=", "\\neq")
    , ("~=", "\\approx")
    , (":=", "\\triangleq")
    , ("<=", "\\leqslant")
    , (">=", "\\geqslant")
    , ("precedes", "\\prec")
    ]

replace :: [String] -> (String, String) -> [String]
replace text (keyword, replacement)
  = map replace' text
    where
      replace' :: String -> String
      replace' word
        | word == keyword = replacement
        | otherwise       = word

embedFile :: String -> String
embedFile text
  = fileStart ++ text ++ fileEnd
    where
      fileStart
        = "\\documentclass{article}\n\
          \\\usepackage{dsfont, amssymb, amsmath}\n\
          \\\usepackage{listings}\n\
          \\\begin{document}\n\
          \\\begin{flushleft}\n"
      fileEnd
        = "\\end{flushleft}\n\
          \\\end{document}"

embedLine :: String -> String
embedLine text
  | text' == "" = "\\newline\\newline"
  | otherwise   = eqntStart ++ text' ++ eqntEnd
    where
      text'
        = dropWhileEnd isSpace $ dropWhile isSpace text
      eqntStart
        = "\\begin{align}\n\
          \\\begin{split}\n"
      eqntEnd
        = "\n\\end{split}\n\
          \\\end{align}"

convertLine :: String -> String
convertLine ('#' : ' ' : text)
  = text
convertLine line
  = embedLine $ unwords $ foldl replace (words line) conversionMap

convert :: String -> String
convert text
  = embedFile $ unlines $ map convertLine $ lines text

pipedInput :: IO ()
pipedInput
  = interact convert

fileInput :: String -> IO ()
fileInput inputFile
  = do
    contents <- readFile inputFile
    putStrLn $ convert contents

fileInputOutput :: String -> String -> IO ()
fileInputOutput inputFile outputFile
  = do
    contents <- readFile inputFile
    writeFile outputFile $ convert contents

usage :: IO ()
usage
  = do
    putStrLn "Invalid arguments"
    putStrLn "Usage: logitex [filename] [output]"

main :: IO ()
main = do
  args <- getArgs
  case args of
    []                      -> pipedInput
    [inputFile]             -> fileInput inputFile
    [inputFile, outputFile] -> fileInputOutput inputFile outputFile
    _                       -> usage
