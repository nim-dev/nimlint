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
  # TODO: use getAppFileName() or getCurrentCompilerExe() to forward nim
  # exec "testament all"
  exec "nim r tests/core/tnimlint.nim"

# TODO
# requires "compiler"
