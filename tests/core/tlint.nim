import std/[os]
import lint

import lintpkg/submodule

proc main =
  doAssert getWelcomeMessage() == "Hello, World!" # palceholder

  const fileInput = currentSourcePath.parentDir / "example.nim"
  const buildDir = currentSourcePath.parentDir.parentDir.parentDir / "build"
  createDir buildDir
  const fileOutput = buildDir / fileInput.lastPathPart
  main(fileInput, fileOutput)

main()
