import terminal, winlean, strutils, math
import utility/keys

export keys

type  
    Position* = tuple[x,y:int]

    Input* = object
        text*:string
        lastKey*:int
        position*:Position
        prompt*:string
        index*:int
        
        returnKey:int


proc getHandle*():Handle =
    return getStdHandle(STD_OUTPUT_HANDLE)


proc getPos*(): Position =
    return getCursorPos( getHandle() )


proc setPos*(pos:Position) =
    setCursorPos(getHandle(), pos.x, pos.y)


proc newPos*(original:Position, text:string): Position = 
    let winSize = terminalSize()
    let newY:int = original.y + math.floor((text.len + original.x) / (winSize.w)).int
    let newX:int = (original.x + text.len) mod winSize.w

    return (x:newX, y:newY)


proc newPos*(original:Position, amount:int): Position = 
    let winSize = terminalSize()
    let newY:int = original.y + math.floor((amount + original.x) / (winSize.w)).int
    let newX:int = (original.x + amount) mod winSize.w

    return (x:newX, y:newY)


proc clearLine*(line:int, amount:int=1) =
    let currentPos:Position = getPos()
    let winSize = terminalSize()
   
    hideCursor(stdout)
    setCursorPos(getHandle(), 0, line)
    echo " ".repeat(winSize.w * amount)
    setPos(currentPos)
    showCursor(stdout)


proc clearLine*(line:int, text:string) = 
    let currentPos:Position = getPos()
    let winSize = terminalSize()
    let lineAmount:int = math.ceil(text.len / winSize.w).int

    hideCursor(stdout)
    setCursorPos(getHandle(), 0, line)
    echo text & " ".repeat(winSize.w * lineAmount)[text.len..^1]
    setPos(currentPos)
    showCursor(stdout)


proc newREPL*(prompt:string="", returnKey:int=Enter):Input =
    return Input(prompt:prompt, text:"", returnKey:returnKey, position:getPos())


proc handleInput*(inp:var Input, display:bool=true): bool = 
    if display:
        clearLine(inp.position.y, inp.prompt & inp.text)        
        setPos(inp.position)
        echo inp.prompt, inp.text
        setPos(newPos(inp.position, (inp.prompt & inp.text).len - inp.index))

    let key:int = msvcrt_getch().getKey

    inp.lastKey = key

    if key in 33..126:
        inp.text.insert($chr(key), inp.text.len - inp.index)

    elif key == Space:
        inp.text.insert(" ", inp.text.len - inp.index)

    elif key == Backspace and inp.text != "" and inp.index != inp.text.len:
        inp.text = inp.text[0..^(inp.index+2)] & inp.text[^(inp.index)..^1]

    elif inp.lastKey == ArrowLeft and inp.index < inp.text.len:
        inp.index += 1
    
    elif inp.lastKey == ArrowRight and inp.index > 0:
        inp.index -= 1

    elif inp.lastKey == Delete and inp.text != "" and inp.index != 0:
        inp.text = inp.text[0..^(inp.index+1)] & inp.text[^(inp.index-1)..^1]
        inp.index -= 1

    elif key == inp.returnKey:
        return false

    return true