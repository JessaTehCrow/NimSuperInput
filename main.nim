import dynlib
import tables

{.pragma: load, gcsafe, stdcall.}

type 
    LibFuncs = seq[array[2,string]]
    LibLookup = Table[string, Table[string, Function]]

    Load = proc():LibFuncs {.load.}
    Normal = proc(inp:string) {.load.}

    Function* = object
        identifier*: string
        procPointer*: pointer
    
    ShellKernel* = object
        lastCommand*:string
        commands*:LibLookup 


# Get function based on string

# Call function
proc call(f:Function, userInput:string) =
    case f.identifier:
        of "Normal": 
            let casted:Normal = cast[Normal](f.procPointer)
            casted(userInput)


# Load library
proc load(lib:string, libs: var LibLookup) =
    let shortName:string = lib[0..^5]
    var funcs:Table[string, Function] = initTable[string,Function]()

    let library = loadLib(lib)
    let function = cast[Load](library.symAddr("load"))

    echo "Loading functions"

    for f in function():
        let point:pointer = library.symAddr(f[0])

        let newFunction:Function = Function(identifier:f[1], procPointer:point) 
        funcs[f[0]] = newFunction
        echo "'",f[0],"' Loaded sucessfully"
    
    libs[shortName] = funcs


var kernel:ShellKernel = ShellKernel()

var libs:LibLookup = initTable[string, Table[string, Function]]()
kernel.commands = libs

# load("lib.dll", libs)