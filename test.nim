import terminal, winlean, strutils

type  
    Position = tuple[x,y:int]

const
    NormalKeys = 33..126
    Esc = 27
    Enter = 12
    CtrlC = 3
    Backspace = 8
    Space = 32

    Arrows = @[-1,-2,-3,-4]
    ArrowLeft = -1
    ArrowRight = -2
    ArrowUp = -3
    ArrowDown = -4

    Func1 = 59
    Func2 = 69
    Func3 = 61
    Func4 = 62 
    Func5 = 63
    Func6 = 64
    Func7 = -5
    Func8 = -6
    Func9 = -7
    Func10 = -8
    Func11 = -9
    Func12 = -10


proc getch(): cint {.importc:"_getch", dynlib:"msvcrt.dll".}


proc getHandle():Handle =
    return getStdHandle(STD_OUTPUT_HANDLE)


proc getPos(): Position =
    return getCursorPos( getHandle() )


proc setPos(pos:Position) =
    setCursorPos(getHandle(), pos.x, pos.y)


proc clearLine(line:int) =
    let currentPos:Position = getPos()
    let winSize = terminalSize()

    setCursorPos(getHandle(), 0, line)
    echo " ".repeat(winSize.w)
    setCursorPos(getHandle(), currentPos.x, currentPos.y)


proc getInput(prompt:string):string =
    var input:string = ""
    var index:int = 0


proc getKey(key:cint): cint = 
    if key == 0:
        echo "Special 0: ", getch()

    elif key == 224:
        let special = getch()
        case special
            of 75: return ArrowLeft
            of 77: return ArrowRight
            of 72: return ArrowUp
            of 80: return ArrowDown
            else:
                echo key
    
    return key


var input:string = ""
var index:int = 0

while true:
    let key = getch().getKey    

    if key in @[Esc,CtrlC]:
        break

    elif key == Backspace:
        input = input[0..^2]

    elif key == Space:
        input &= " "

    elif key in NormalKeys:
        input &= chr(key)
    else:
        echo key

    echo input