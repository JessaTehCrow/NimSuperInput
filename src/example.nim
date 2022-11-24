import REPL

var input = ""
var index = 0

var pos:Position = getPos()

while true:
    setPos(pos)
    let key:cint = getch().getKey

    case key
        of Esc, CtrlC, Enter: 
            break

        of Backspace: 
            input = input[0..^2]

        of Space: 
            input &= " "

        of 33..126: 
            input &= chr(key)

        else:
            echo "Unknown key: ", key

    clearLine(pos.y)
    echo input