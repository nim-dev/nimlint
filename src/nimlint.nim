#[
TODO: not portable, needs instead: `requires "compiler"`
]#
import ../compiler/[ast, idents, msgs, syntaxes, options, pathutils]
import std/[os, strformat, strutils, parseutils, sets]
import std/private/miscdollars # avoids code duplication


type
  HintStateKind* = enum
    # doc comments
    hintBackticks
    hintCodeBlocks
    hintFirstChar
    hintLastChar
    # functions
    hintFunc
    hintIsMainModule
    # testament
    hintExitcode
    hintAssert

  HintState* = object
    kind: HintStateKind
    info: tuple[file: string, line, col: int]

const
  hintStateKindTable: array[8, string] = ["double backticks => single backtick",
      "code blocks => runnableExamples",
      "the first char should be upper",
      "the last char should not be in alphabet",

      "proc + noSideEffect => func",
      "isMainModule in stdlib => moving to tests/*/*.nim",

      "exitcode: 0 is usually useless",
      "assert in tests => doAssert"
      ]

static: doAssert hintStateKindTable.high == HintStateKind.high.ord

proc initHintState(kind: HintStateKind, file: string, line, col: int): HintState =
  HintState(kind: kind, info: (file, line, col))

template add(
  tabs: var seq[HintState], kind: HintStateKind,
  conf: ConfigRef, file: string, line, col: int
) =
  tabs.add initHintState(kind, file, line, col)

proc add(tabs: var seq[HintState], kind: HintStateKind, conf: ConfigRef, n: PNode) =
  let info = n.info
  let file = conf.toFullPath(info.fileIndex)
  tabs.add(kind, conf, file, info.line.int, info.col.int)

const
  SpecialChars = {'\r', '\n', '`'}
  testsPath = "tests"

proc cleanWhenModule(conf: ConfigRef, n: PNode, hintTable: var seq[HintState]) =
  if n.len > 0 and n[0].kind == nkElifBranch:
    let son = n[0]
    if son[0].kind == nkIdent and cmpIgnoreStyle(son[0].ident.s, "isMainModule") == 0:
      hintTable.add(hintIsMainModule, conf, n)

proc cleanCodeBlocks(
  comments: string, start: var int, conf: ConfigRef, n: PNode, hintTable: var seq[HintState]
) =
  const cb = ".. code-block::"
  if start + cb.high < comments.len:
    if comments.startsWith(cb):
    # if cmpIgnoreStyle(comments.substr(start, cb.high), cb) == 0:
      hintTable.add(hintCodeBlocks, conf, n)
      inc(start, cb.high)

proc cleanComment(conf: ConfigRef, n: PNode, hintTable: var seq[HintState]) =
  let comments = n.comment


  if comments.len > 0:
    var start = 0
    var line = n.info.line.int
    var ticks = initHashSet[int]()

    if isLowerAscii(comments[0]):
      hintTable.add(hintFirstChar, conf, n)
    elif isAlphaAscii(comments[^1]):
      hintTable.add(hintLastChar, conf, n)

    while start < comments.len:
      cleanCodeBlocks(comments, start, conf, n, hintTable)
      let incr = skipUntil(comments, SpecialChars, start)
      inc(start, incr)
      if start < comments.len:
        case comments[start]
        of '\n':
          inc start
          inc line
          cleanCodeBlocks(comments, start, conf, n, hintTable)
        of '`':
          if start + 1 < comments.len and comments[start+1] == '`':
            if line notin ticks:
              hintTable.add(hintBackticks, conf, conf.toFullPath(n.info.fileIndex), line, 0)
              ticks.incl(line)
            inc start
          inc start
        else:
          inc start


proc clean(conf: ConfigRef, n: PNode, hintTable: var seq[HintState], infile: string) =
  case n.kind
  of nkImportStmt, nkExportStmt, nkCharLit..nkUInt64Lit,
      nkFloatLit..nkFloat128Lit, nkStrLit..nkTripleStrLit:
    discard
  of nkWhenStmt:
    # Handles the most common case
    # {
    #   "kind": "nkWhenStmt",
    #   "typ": "nil",
    #   "sons": [{
    #     "kind": "nkElifBranch",
    #     "typ": "nil",
    #     "sons": [{
    #       "kind": "nkIdent",
    #       "typ": "nil",
    #       "ident": "isMainModule"
    #     }, {
    #       "kind": "nkStmtList",
    #       "typ": "nil"
    cleanWhenModule(conf, n, hintTable)
  of nkSym:
    discard
  of nkProcDef:
    for son in n[pragmasPos]:
      if cmpIgnoreStyle(son.ident.s, "noSideEffect") == 0:
        hintTable.add(hintFunc, conf, n)
        break
    clean(conf, n[bodyPos], hintTable, infile)
  of nkFuncDef:
    discard
  of nkIdent:
    var path = infile.expandFileName
    if path.find(testsPath) >= 0:
      if cmpIgnoreStyle(n.ident.s, "assert") == 0:
        hinttable.add(hintAssert, conf, n)
  of nkCommentStmt:
    cleanComment(conf, n, hintTable)
  else:
    for s in n.sons:
      clean(conf, s, hintTable, infile)

proc prettyPrint*(infile, outfile: string, hintTable: var seq[HintState]) =
  # TODO: is outfile written to?
  # outfile needs nimpretty
  var conf = newConfigRef()
  let fileIdx = fileInfoIdx(conf, AbsoluteFile infile)
  let f = splitFile(outfile.expandTilde)
  conf.outFile = RelativeFile f.name & f.ext
  conf.outDir = toAbsoluteDir f.dir
  var parser: Parser
  var cache = newIdentCache()

  if setupParser(parser, fileIdx, cache, conf):
    var ast = parseFile(conf.projectMainIdx, cache, conf)
    clean(conf, ast, hintTable, infile)

proc toString(a: HintState, verbose: bool): string =
  result = fmt"[lint] {a.kind}: "
  let loc = a.info
  result.toLocation(loc.file, loc.line, loc.col)

  if verbose:
    result.add "\n" & hintStateKindTable[a.kind.ord] & "\n"

proc `$`*(a: HintState): string =
  toString(a, false)

proc main*(input, output: string, verbose = true) =
  var hintTable: seq[HintState]
  prettyPrint(input, output, hintTable)

  for item in hintTable:
    echo toString(item, verbose)

when isMainModule:
  import cligen
  dispatch main
