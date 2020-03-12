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
    want ["_build/run" <.> exe, "_build2/run2" <.> exe, "_build_hs" </> "main" <.> exe]

    phony "clean" $ do
        putInfo "Cleaning files in _build"
        removeFilesAfter "_build" ["//*"]
        putInfo "Cleaning files in _build2"
        removeFilesAfter "_build2" ["//*"]

    "_build/run" <.> exe %> \out -> do
        cs <- getDirectoryFiles "" ["c_src//*.c"]
        let os = ["_build" </> c -<.> "o" | c <- cs]
        need os
        cmd_ "gcc -o" [out] os
    
    "_build2/run2" <.> exe %> \out -> do
        cs <- getDirectoryFiles "" ["c2_src//*.c"]
        let os = ["_build2" </> c -<.> "o" | c <- cs]
        need os
        cmd_ "gcc -o" [out] os
    
    "_build_hs" </> "main" <.> exe %> \out -> do
      src <- getDirectoryFiles "" ["hs_src//*.hs"]
      need src
      cmd_
        "ghc"
        ("hs_src" </> "main.hs")
        "-isrc"
        "-outputdir"
        "_build_hs"
        "-o"
        out


    "_build//*.o" %> \out -> do
        let c = dropDirectory1 $ out -<.> "c"
        let m = out -<.> "m"
        cmd_ "gcc -c" [c] "-o" [out] "-MMD -MF" [m]
        neededMakefileDependencies m
    
    "_build2//*.o" %> \out -> do
        let c = dropDirectory1 $ out -<.> "c"
        let m = out -<.> "m"
        cmd_ "gcc -c" [c] "-o" [out] "-MMD -MF" [m]
        neededMakefileDependencies m
    
    
