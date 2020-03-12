{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
module Main (main) where
{-
import Import
import Run
import RIO.Process
import Options.Applicative.Simple
import qualified Paths_manualShake
-}
import Import

import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util

main :: IO ()
main = shakeArgs shakeOptions{shakeFiles="_build"} $ do
    want ["_build/run" <.> exe]

    phony "clean" $ do
        putInfo "Cleaning files in _build"
        removeFilesAfter "_build" ["//*"]

    "_build/run" <.> exe %> \out -> do
        cs <- getDirectoryFiles "" ["//*.c"]
        let os = ["_build" </> c -<.> "o" | c <- cs]
        need os
        cmd_ "gcc -o" [out] os

    "_build//*.o" %> \out -> do
        let c = dropDirectory1 $ out -<.> "c"
        let m = out -<.> "m"
        cmd_ "gcc -c" [c] "-o" [out] "-MMD -MF" [m]
        neededMakefileDependencies m
{-
main :: IO ()
main = do
  (options, ()) <- simpleOptions
    $(simpleVersion Paths_manualShake.version)
    "Header for command line arguments"
    "Program description, also for command line arguments"
    (Options
       <$> switch ( long "verbose"
                 <> short 'v'
                 <> help "Verbose output?"
                  )
    )
    empty
  lo <- logOptionsHandle stderr (optionsVerbose options)
  pc <- mkDefaultProcessContext
  withLogFunc lo $ \lf ->
    let app = App
          { appLogFunc = lf
          , appProcessContext = pc
          , appOptions = options
          }
     in runRIO app run
-}