proc msvcrt_getch*(): cint {.importc:"_getch", dynlib:"msvcrt.dll".}

const
    Esc* = 27
    Enter* = 13
    Backspace* = 8
    Space* = 32
    Tab* = 9

    CtrlA* = 1
    CtrlB* = 2
    CtrlC* = 3
    CtrlD* = 4
    CtrlE* = 5
    CtrlF* = 6
    CtrlG* = 7
    CtrlJ* = 10
    CtrlK* = 11
    CtrlL* = 12
    CtrlN* = 14
    CtrlO* = 15
    CtrlP* = 16
    CtrlQ* = 17
    CtrlR* = 18
    CtrlS* = 19
    CtrlT* = 20
    CtrlU* = 21
    CtrlV* = 22
    CtrlW* = 23
    CtrlX* = 24
    CtrlY* = 25
    CtrlZ* = 26
    CtrlArrLeft* = 115
    CtrlArrUp* = 141
    CtrlArrRight* = 116
    CtrlArrDown* = 145

    ArrowLeft* = -1
    ArrowRight* = -2
    ArrowUp* = -3
    ArrowDown* = -4

    Func1* = -5
    Func2* = -6
    Func3* = -7
    Func4* = -8 
    Func5* = -9
    Func6* = -10
    Func7* = -11
    Func8* = -12
    Func9* = -13
    Func10* = -14
    Func11* = -15
    Func12* = -16

    Insert* = -17
    Delete* = -18

    PageUp* = -19
    PageDown* = -20

proc getKey*(key:cint): cint = 
    if key == 0:
        let special = msvcrt_getch()
        case special
            of 59: return Func1
            of 60: return Func2
            of 61: return Func3
            of 62: return Func4
            of 63: return Func5
            of 64: return Func6
            of 65: return Func7
            of 66: return Func8
            of 67: return Func9
            of 68: return Func10
            of 72: return ArrowUp
            of 75: return ArrowLeft
            of 77: return ArrowRight
            of 80: return ArrowDown
            of 82: return Insert
            of 83: return Delete
            else:
                echo "\nspecial 0: ",special

    elif key == 224:
        let special = msvcrt_getch()
        case special
            of 75: return ArrowLeft
            of 77: return ArrowRight
            of 72: return ArrowUp
            of 73: return PageDown
            of 80: return ArrowDown
            of 81: return PageDown
            of 82: return Insert
            of 83: return Delete
            of 133: return Func11
            of 134: return Func12
            else:
                echo "\nspecial 224: ", special

    return key