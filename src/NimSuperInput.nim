import terminal, winlean, strutils, math
import nimcolor
import NimSuperInput/keys
import os

# Neccecary to enable colors
discard execShellCmd("")

export keys

type  
    Position* = tuple[x,y:int]

    Input* = object
        history*:seq[string]
        historyIndex*:int
        suggestions*:seq[string]
        suggestionIndex*:int
        displayText*:string
        hint*:string
        text*:string
        oldText*:string
        lastKey*:int
        position*:Position
        prompt*:string
        index*:int
        oldIndex*:int

        returnKey:int

proc `-`(a,b:Position): Position = 
    return (x: a.x - b.x, y: a.y - b.y)


proc getHandle():Handle =
    return getStdHandle(STD_OUTPUT_HANDLE)


proc getPos(): Position =
    return getCursorPos( getHandle() )


proc setPos(pos:Position) =
    setCursorPos(getHandle(), pos.x, pos.y)


proc newPos(original:Position, text:string): Position = 
    let winSize = terminalSize()
    let newY:int = original.y + math.floor((text.len + original.x) / (winSize.w)).int
    let newX:int = (original.x + text.len) mod winSize.w

    return (x:newX, y:newY)


proc newPos(original:Position, amount:int): Position = 
    let winSize = terminalSize()
    let newY:int = original.y + math.floor((amount + original.x) / (winSize.w)).int
    let newX:int = (original.x + amount) mod winSize.w

    return (x:newX, y:newY)


proc clearLine(line:int, amount:int=1) =
    let currentPos:Position = getPos()
    let winSize = terminalSize()
   
    hideCursor(stdout)
    setCursorPos(getHandle(), 0, line)
    echo " ".repeat(winSize.w * amount)
    setPos(currentPos)
    showCursor(stdout)


proc clearLine(line:int, displayText:string, clearAmount:int) =
    let currentPos:Position = getPos()
    let winSize = terminalSize()
    let amount = max((winSize.w * clearAmount) - displayText.removeColor.len, 0)

    hideCursor(stdout)
    setCursorPos(getHandle(), 0, line)
    stdout.write(displayText & " ".repeat(amount))
    setPos(currentPos)
    showCursor(stdout)


proc input*(prompt:string="", returnKey:int=Enter, suggestions:seq[string]= @[]):Input =
    Input(prompt:prompt, text:"", returnKey:returnKey, position:getPos(), suggestions:suggestions)


proc reset*(handler:var Input) =
    var newHandler = input(handler.prompt, handler.returnKey, handler.suggestions)
    newHandler.history = handler.history
    handler = newHandler 


proc naiveSplit(str:string, charSplit:char=' ', reserve:bool=false):seq[string] = 
    var temp:string
    var wasChar:bool

    for c in str:
        if (c==charSplit) != wasChar and temp != "":
            result.add(temp)
            temp = ""

        if reserve or c != charSplit:
            temp &= c
        
        wasChar = c == charSplit

    if temp != "":
        result.add(temp)


proc getSuggestion(text:string, suggestions:seq[string]): string = 
    if text.len == 0: return

    for k in suggestions:
        let raw = k.removeAllColor
        if raw.startsWith(text) and text != raw:
            return raw[text.len..^1]


proc allSuggestions(text:string, suggestions:seq[string]): seq[string] =
    for s in suggestions:
        let raw = s.removeAllColor
        if raw.startsWith(text) and text != raw:
            result.add(s)


proc handleInput*(inp:var Input, display:bool=true): bool = 
    if inp.lastKey != 0 and (inp.prompt & inp.displayText).removeColor == (inp.prompt & inp.text).removeColor:
        let curpos = getPos()
        let span = newPos((x:0,y:0), (inp.prompt & inp.oldText).removeColor.len - inp.oldIndex)
        let actualPos = curpos - span
        inp.position = actualPos

    let suggestion     = getSuggestion(inp.text.split()[^1], inp.suggestions)
    let oldSuggestions = allSuggestions(inp.oldText.split()[^1], inp.suggestions)
    let newSuggestions = allSuggestions(inp.text.split()[^1], inp.suggestions)

    let winSize = terminalSize()
    let newCursorPos = newPos(inp.position, (inp.prompt & inp.displayText.removeColor).len - inp.index)

    if display:
        clearLine(inp.position.y, inp.prompt & inp.displayText, math.ceil((inp.prompt & inp.oldText).len / winSize.w).int)
        hideCursor()
        setPos(inp.position)
        writeLine(stdout, inp.prompt & inp.displayText & ("&gray;" & suggestion & inp.hint).color)
        setPos(newCursorPos)
        flushFile(stdout)
        showCursor()

    let key:int = msvcrt_getch().getKey
    let secondlast = inp.lastKey
    var oldText = inp.text

    inp.oldIndex = inp.index
    inp.lastKey = key

    if key in 33..126:
        inp.text.insert($chr(key), inp.text.len - inp.index)

    elif inp.lastKey == Space:
        inp.text.insert(" ", inp.text.len - inp.index)

    elif inp.lastKey == Backspace and inp.text != "" and inp.index != inp.text.len:
        inp.text = inp.text[0..^(inp.index+2)] & inp.text[^(inp.index)..^1]
    
    elif key == CtrlBackspace and inp.text != "" and inp.index != inp.text.len:
        inp.text = naiveSplit(inp.text[0..^(inp.index+2)], reserve=true)[0..^2].join() & inp.text[(^inp.index)..^1]

    elif inp.lastKey == ArrowLeft and inp.index < inp.text.len:
        inp.index += 1
    
    elif inp.lastKey == ArrowRight and inp.index > 0:
        inp.index -= 1
    
    elif inp.lastKey == ArrowUp and inp.historyIndex < inp.history.len:
        inp.historyIndex += 1
        inp.text = inp.history[^inp.historyIndex]

    elif inp.lastKey == ArrowDown and inp.historyIndex > 0:
        inp.historyIndex -= 1
        if inp.historyIndex == 0:
            inp.text = ""
        else:
            inp.text = inp.history[^inp.historyIndex] 

    elif inp.lastKey == Tab:
        if oldSuggestions.len > 0 and secondlast == Tab:
            var tempPos = newPos(inp.position, (inp.prompt & inp.oldText).removeColor.len - inp.index)
            inp.text = inp.oldText & oldSuggestions[inp.suggestionIndex mod oldSuggestions.len].removeAllColor[inp.oldText.split()[^1].len..^1]
            oldText = inp.oldText
            inp.suggestionIndex += 1
            hideCursor()
            echo ("\n&gray;" & oldSuggestions.join("   ")).color
            setPos(tempPos)
        else:
            if newSuggestions.len > 10:
                var tempPos = newPos(inp.position, (inp.prompt & inp.text).removeColor.len - inp.index)
                echo "\n&yellow; More than 10 suggestions, press tab again to see all.".color
                setPos(tempPos)
            inp.text &= suggestion.removeAllColor

    elif inp.lastKey == Escape:
        if secondlast == Tab:
            inp.text = inp.oldText
            inp.index = min(0, inp.text.len - inp.index)
        else:
            inp.text = ""
            inp.index = 0

    elif inp.lastKey == Home:
        inp.index = inp.text.len
    
    elif inp.lastKey == End:
        inp.index = 0

    elif inp.lastKey == Delete and inp.text != "" and inp.index != 0:
        inp.text = inp.text[0..^(inp.index+1)] & inp.text[^(inp.index-1)..^1]
        inp.index -= 1

    elif key == inp.returnKey:
        return false
    
    # Set old text as well as clear lines for suggestions
    inp.displayText = inp.text
    inp.oldText = oldText

    if inp.lastKey != Tab and secondlast == Tab:
        inp.suggestionIndex = 0

        var newLine = newPos(inp.position, inp.prompt & inp.oldText)
        clearLine(newLine.y+1, math.ceil(oldSuggestions.join("   ").len / winsize.w).int)

    return true