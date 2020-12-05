import std/[os]
import ../../src/nimlint

proc main =
  const fileInput = currentSourcePath.parentDir / "example.nim"
  const buildDir = currentSourcePath.parentDir.parentDir.parentDir / "build"
  createDir buildDir
  const fileOutput = buildDir / fileInput.lastPathPart
  echo fileOutput
  removeFile fileOutput
  main(fileInput, fileOutput)
  doAssert fileOutput.fileExists, fileOutput
  # TODO: check file content matches some groundtruth

main()
