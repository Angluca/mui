# Package

version       = "2.0.1"
author        = "Angluca"
description   = "A tiny immediate-mode UI library"
license       = "MIT"

installDirs = @["src"]

# Dependencies

requires "nim >= 0.20.0"

taskRequires "test", "sdl2"
taskRequires "test", "opengl"

task test, "Run demo":
  exec "nim c -d:release -r demo/main.nim"
