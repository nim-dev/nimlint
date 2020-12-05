# Package

version       = "0.1.0"
author        = "xflywind + contributors"
description   = "Nim lint tool"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
binDir           = "bin"
bin           = @["nimlint"]


# Dependencies

requires "nim >= 1.5.1"
requires "cligen >= 1.3.2"


task tests, "Test all":
  # exec "testament all"
  nim r tests/core/tnimlint.nim

# TODO
# requires "compiler"
