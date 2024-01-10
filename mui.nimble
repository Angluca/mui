# Package
version       = "2.0.1"
author        = "Angluca"
description   = "A tiny immediate-mode UI library"
license       = "MIT"

installDirs = @["src"]

# Dependencies
requires "nim >= 1.6.6"
requires "sokol"
#requires "sdl2"
#requires "opengl"

task demo, "Run demo":
  withDir "demo/":
    exec "nim c -d:release -r mui-sokol/main.nim"

task test, "Run demo":
  exec "nim c -d:release -r demo/mui-sokol/main.nim"
