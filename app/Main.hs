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
main = do
  build_hs
  build1
  build2

build_hs :: IO ()
build_hs = shakeArgs shakeOptions{shakeFiles="_build"} $ do
    want ["_build" </> "main" <.> exe]

    phony "clean" $ do
        putInfo "Cleaning files in _build_hs"
        removeFilesAfter "_build" ["//*"]

    
    "_build" </> "main" <.> exe %> \out -> do
      src   <- getDirectoryFiles "" ["hs_src//*.hs"]
      cmd_
        "ghc"
        ("hs_src" </> "main.hs")
        "-isrc"
        "-outputdir"
        "_build"
        "-o"
        out
    

build1 :: IO ()
build1 = shakeArgs shakeOptions{shakeFiles="_build"} $ do
    want ["_build/run1" <.> exe]

    phony "clean" $ do
        putInfo "Cleaning files in _build1"
        removeFilesAfter "_build" ["//*"]
        
    "_build/run1" <.> exe %> \out -> do
        cs <- getDirectoryFiles "" ["c_src//*.c"]
        let os = ["_build" </> c -<.> "o" | c <- cs]
        need os
        cmd_ "gcc -o" [out] os
    
     

    "_build//*.o" %> \out -> do
        let c = dropDirectory1 $ out -<.> "c"
        let m = out -<.> "m"
        cmd_ "gcc -c" [c] "-o" [out] "-MMD -MF" [m]
        neededMakefileDependencies m
    
build2 :: IO ()
build2 = shakeArgs shakeOptions{shakeFiles="_build"} $ do
    want [ "_build/run2" <.> exe]

    phony "clean" $ do
        putInfo "Cleaning files in _build2"
        removeFilesAfter "_build" ["//*"]
        
    
    "_build/run2" <.> exe %> \out -> do
        cs <- getDirectoryFiles "" ["c2_src//*.c"]
        let os = ["_build" </> c -<.> "o" | c <- cs]
        need os
        cmd_ "gcc -o" [out] os

    "_build//*.o" %> \out -> do
        let c = dropDirectory1 $ out -<.> "c"
        let m = out -<.> "m"
        cmd_ "gcc -c" [c] "-o" [out] "-MMD -MF" [m]
        neededMakefileDependencies m
    
    
