import std/[os,unittest]
import lint

import lintpkg/submodule

check getWelcomeMessage() == "Hello, World!"

const fileInput = currentSourcePath.parentDir / "example.nim"
const fileOutput = currentSourcePath.parentDir.parentDir / "build/example.nim"
main(fileInput, fileOutput)
