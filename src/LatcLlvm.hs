-- based on test file automatically generated by BNF Converter
module Main where

import System.Environment ( getArgs, getExecutablePath )
import System.Exit ( exitFailure, exitSuccess )
import System.IO (writeFile)
import System.FilePath.Posix (takeExtension, takeBaseName, dropExtension, takeDirectory)
import System.Process (system)
import System.Exit (ExitCode(ExitFailure, ExitSuccess))

import Control.Monad (when)

import AbsLatte
import ErrM
import LexLatte
import ParLatte
import PrintLatte
import SkelLatte
import qualified Frontend.Check as Check
import qualified LlvmBackend.Compile as CompileLlvm
import qualified LlvmBackend.Print as PrintLlvm


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
  latteTree <- parseAndCheck source baseName
  let llvmTree = CompileLlvm.compile latteTree
  let code = PrintLlvm.showModule llvmTree
  putStrLn code
  exitSuccess
  let dir = takeDirectory f
  let droppedExt = dropExtension f
  let newFileName = droppedExt ++ ".ll"
  let bcFName = dir ++ "/" ++ baseName ++ ".bc"
  writeFile newFileName code
  putStrLn $ newFileName ++ " has been created"
  executablePath <- getExecutablePath
  let runtimeLibPath = takeDirectory executablePath ++ "/lib/runtime.bc"
  let llvm_as = "llvm-as  " ++ newFileName ++ " -o " ++ bcFName
  let llvm_link = "llvm-link -o " ++ bcFName ++ " " ++ runtimeLibPath ++ " " ++ bcFName
  let command = llvm_as ++ " && " ++ llvm_link
  putStrLn command
  retCode <- system command
  case retCode of
    (ExitFailure errCode) -> do
      putStrLn $ "llvm-as failed with ret code: " ++ (show errCode)
      exitFailure
    _ -> do
      putStrLn $ bcFName ++ " has been created"
      exitSuccess
  exitSuccess


parseAndCheck :: String -> String -> IO Program
parseAndCheck programText baseName =
  case pProgram (myLexer programText) of
    Bad s -> do
      putStrLn "ERROR"
      putStrLn "Parsing failed"
      putStrLn s
      putStrLn programText
      exitFailure
    Ok tree ->
      case Check.check tree of
        Right optimizedTree -> do
          putStrLn "OK"
          return optimizedTree
        Left error -> do
          putStrLn "ERROR"
          putStrLn $ show error
          exitFailure


usage :: IO ()
usage = do
  putStrLn $ unlines
    [ "usage: Call with one of the following argument combinations:"
    , "  --help   Display this help message."
    , "  file     Compile .lat file to llvm"
    ]
  exitFailure
