# Package

version       = "2.0.1"
author        = "Angluca"
description   = "A tiny immediate-mode UI library"
license       = "MIT"

installDirs = @["src"]

# Dependencies

requires "nim >= 1.6.6"

#taskRequires "test", "sdl2"
#taskRequires "test", "opengl"

task test, "Run demo":
  echo "--- You can use nimble install sdl and opengl"
  echo "1. --- nimble install sdl"
  echo "2. --- nimble install opengl"
  exec "nim c -d:release -r demo/main.nim"
