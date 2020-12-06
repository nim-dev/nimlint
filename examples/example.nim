for i in 1 .. 10:
  echo i

let x = "1234567898765432187652367489668754326789348565784932873456"

## 1134567890
proc hello(a: int) {.nosideeffect.} =
  ## ``Double quote`` should be removed.
  ## Test
  ## .. code-block::
  ##    echo 23
  runnableExamples:
    ## Hello Kitty
    assert 12 == 12
  debugecho "Hello, World"
  assert 12 == 12
  when isMainModule:
    assert 1 == 1

## .. code-block::nim
##    echo 23
## test ``double ticks``
## 

func rest = discard

when isMainModule:
  hello(12)
