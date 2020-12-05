import ../compiler / [ast, idents, msgs, syntaxes, options, pathutils]

from ../compiler/renderer import renderTree
from ../compiler/astalgo import debug

import os

type
  PrettyOptions* = object
    indWidth*: Natural
    maxLineLen*: Positive

proc clean(conf: ConfigRef, n: PNode) =
  if n.comment.len != 0:
    echo n.comment
  case n.kind
  of nkImportStmt, nkExportStmt, nkCharLit..nkUInt64Lit,
      nkFloatLit..nkFloat128Lit, nkStrLit..nkTripleStrLit:
    discard
  of nkIdent, nkSym:
    discard
  else:
    for s in n.sons:
      clean(conf, s)

proc prettyPrint*(infile, outfile: string, opt: PrettyOptions) =
  var conf = newConfigRef()
  let fileIdx = fileInfoIdx(conf, AbsoluteFile infile)
  let f = splitFile(outfile.expandTilde)
  conf.outFile = RelativeFile f.name & f.ext
  conf.outDir = toAbsoluteDir f.dir
  var parser: Parser
  var cache = newIdentCache()
  if setupParser(parser, fileIdx, cache, conf):
    var ast = parseFile(conf.projectMainIdx, cache, conf)
    clean(conf, ast)
    closeParser(parser)

proc main*(fileInput, fileOutput: string) =
  var outfile, outdir: string

  var infiles = newSeq[string]()
  var outfiles = newSeq[string]()

  var backup = false
    # when `on`, create a backup file of input in case
    # `prettyPrint` could over-write it (note that the backup may happen even
    # if input is not actually over-written, when nimpretty is a noop).
    # --backup was un-documented (rely on git instead).
  var opt = PrettyOptions(indWidth: 0, maxLineLen: 80)

  prettyPrint(fileInput, fileOutput, opt)

when isMainModule:
  main("example.nim", "out.nim")
