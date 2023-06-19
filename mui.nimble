# Package
version       = "2.0.1"
author        = "Angluca"
description   = "A tiny immediate-mode UI library"
license       = "MIT"

installDirs = @["src"]

# Dependencies
requires "nim >= 1.6.6"
requires "sdl2"
requires "opengl"

task test, "Run demo":
  withDir "demo/":
    exec "nim c -r main.nim"
  #exec "nim c -d:release -r demo/main.nim"
