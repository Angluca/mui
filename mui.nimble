# Package

version       = "2.0.1"
author        = "Angluca"
description   = "A tiny immediate-mode UI library"
license       = "MIT"

installDirs = @["src", "doc"]

# Dependencies

requires "nim >= 0.19.4"

task test, "Run demo":
  echo "================================"
  echo "If you want build demo:"
  echo "require [nimble install sdl2]"
  echo "require [nimble install opengl]"
  echo "require [sdl2 library]"
  echo "================================"
  exec "nim c -d:release -r demo/main.nim"
