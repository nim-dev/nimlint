import std/os
import lint
# import lintpkg/submodule # other imports
const fileInput = currentSourcePath.parentDir / "example.nim"
const fileOutput = currentSourcePath.parentDir.parentDir / "build/example.nim"
main(fileInput, fileOutput)
