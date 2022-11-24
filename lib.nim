{.pragma: usable, dynlib, stdcall, exportc.}

type
    LibFuncs = seq[array[2,string]]


proc load():LibFuncs {.usable.} =
    @[
        ["display","Normal"]
    ]


proc prefix():string =
    return "Prefix: "

proc display(inp:string) {.usable.} = 
    echo prefix(), inp
