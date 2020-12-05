# lint
nim-lint for developing

Ref RFC https://github.com/timotheecour/Nim/issues/415

## lint items
- [ ] code block => runnableExamples
- [ ] proc + noSideEffect => func
- [ ] assert in a test file => doAssert
- [x] isMainModule in stdlib => recommend moving to tests/stdlib/tfoo.nim
- [ ] double backticks => single backticks
- [ ] capitalize the fist letter
- [ ] lots of testament specific checks (eg `exitcode: 0` usually useless)
- [ ] etc, countless things that would be best done as a tool instead of relying on every reviewer to check all of those in every PR (plus for making it easier to improve stdlib + third party projects)

## TODO

- [ ] Better messages with filename, line and col number

## Usage

Type `nim c -r lint.nim`.
