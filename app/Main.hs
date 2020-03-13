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
import qualified Prelude as P
import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util



import Control.Applicative
import Control.Arrow
import Control.Monad
import Data.Version as V

main :: IO ()
main = do
  build_hs
  --build1
  --build2
  

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


{-
All the imports for: shake-language-c: Utilities for cross-compiling with Shake
which is not working as very hard to work with. But I should not go with this because I don't need cross-compiler.
Intsead stick with shake, and figure out how to do gcc calls for static library.
import qualified Development.Shake.Language.C.Target.OSX as OSX
import qualified Development.Shake.Language.C.Target.Linux as Linux
--import qualified Development.Shake.Language.C.Target as Target
import qualified Development.Shake.Language.C.Host as Host
import qualified Development.Shake.Language.C as C
import qualified Development.Shake.Language.C.ToolChain as ToolChain

--https://stackoverflow.com/questions/28142660/shake-for-cross-compilations
buildLibrary :: IO ()
buildLibrary = shakeArgs shakeOptions{shakeFiles="_build"} $ do
  let
    --target = OSX.target (Target.X86 Target.I386)
    --target = Host.defaultToolChain
    --targets = [C.Target C.Linux (C.Platform "linux")]
    
    
  libs <- do
    
    let
      target = Linux.target $ C.X86 C.X86_64
      toolChain = Linux.toolChain ToolChain.GCC
    C.staticLibrary ("_build" </> "libsupply.a") _ {-toolChain
          ("_build" </> "libsupply.a")
          (return $ 
               C.append C.compilerFlags [(Just C.C, ["-std=c++11"])]
           >>> C.append C.compilerFlags [(Nothing, ["-O3"])]
           >>> C.append C.userIncludes ["include"] )
          (getDirectoryFiles "" ["cobj_src//*.c"])-}
              
  
  want [libs]
  
-}
