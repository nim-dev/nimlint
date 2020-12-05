import std/[os]
import lint

import lintpkg/submodule
doAssert getWelcomeMessage() == "Hello, World!" # palceholder

const fileInput = currentSourcePath.parentDir / "example.nim"
const fileOutput = currentSourcePath.parentDir.parentDir / "build/example.nim"
main(fileInput, fileOutput)
