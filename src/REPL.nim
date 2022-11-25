import terminal, winlean, strutils, math
import keys

export keys

type  
    Position* = tuple[x,y:int]

    Input* = object
        text*:string
        lastKey*:int
        position*:Position
        prompt*:string
        
        returnKey:int


proc getHandle*():Handle =
    return getStdHandle(STD_OUTPUT_HANDLE)


proc getPos*(): Position =
    return getCursorPos( getHandle() )


proc setPos*(pos:Position) =
    setCursorPos(getHandle(), pos.x, pos.y)


proc clearLine*(line:int, amount:int=1) =
    let currentPos:Position = getPos()
    let winSize = terminalSize()
   
    hideCursor(stdout)
    setCursorPos(getHandle(), 0, line)
    echo " ".repeat(winSize.w * amount)
    setCursorPos(getHandle(), currentPos.x, currentPos.y)
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


proc newPos(original:Position, text:string): Position = 
    let winSize = terminalSize()
    let newY:int = original.y + math.floor((text.len + original.x) / (winSize.w)).int
    let newX:int = (original.x + text.len) mod winSize.w

    return (x:newX, y:newY)


proc newInput*(prompt:string="", returnKey:int=Enter):Input =
    return Input(prompt:prompt, text:"", returnKey:returnKey, position:getPos())


proc handleInput*(inp:var Input, display:bool=true): bool = 
    if display:
        clearLine(inp.position.y, inp.prompt & inp.text)        
        setPos(inp.position)
        echo inp.prompt, inp.text
        setPos(newPos(inp.position, inp.prompt & inp.text))
    
    let key:int = msvcrt_getch().getKey

    inp.lastKey = key

    if key in 33..126:
        inp.text &= chr(key)

    elif key == Space:
        inp.text &= " "

    elif key == Backspace and inp.text.len > 0:
        inp.text = inp.text[0..^2]

    elif key == inp.returnKey:
        return false
    
    return true