-- based on test file automatically generated by BNF Converter
module Main where

import System.Environment ( getArgs )
import System.Exit ( exitFailure, exitSuccess )
import System.IO (writeFile)
import System.FilePath.Posix (takeExtension, takeBaseName, dropExtension, takeDirectory)
--import System.Process (system)
import System.Exit (ExitCode(ExitFailure, ExitSuccess))

import Control.Monad (when)

import AbsLatte
import ErrM
import LexLatte
import ParLatte
import PrintLatte
import SkelLatte


main :: IO ()
main = do
  args <- getArgs
  case args of
    [f] -> compileFile f
    _ -> usage


compileFile :: FilePath -> IO ()
compileFile f = do
  when ((takeExtension f) /= ".lat")
    (putStrLn "Incorrect file extension - expected .lat" >> exitFailure)
  let baseName = takeBaseName f
  when (baseName == "")
    (putStrLn "Filename cannot be empty" >> exitFailure)
  source <- readFile f
  code <- compile source baseName
  putStrLn $ code


compile :: String -> String -> IO String
compile programText baseName =
  case pProgram (myLexer programText) of
    Bad s -> do
      putStrLn "\nParsing failed\n"
      putStrLn programText
      exitFailure
    Ok tree -> do
      return $ show $ tree


usage :: IO ()
usage = do
  putStrLn $ unlines
    [ "usage: Call with one of the following argument combinations:"
    , "  --help   Display this help message."
    , "  file     Compile .lat file to llvm"
    ]
  exitFailure
