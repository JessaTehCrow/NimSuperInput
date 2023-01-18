# NimSuperInput
Custom build Input Loop for windows with better features

## Functionality

- Per character input callback. Useful for custom syntax highlighting.
- Suggestions with tab-complete
- Hinting
- Special key handling (home & end, ctrl+[arrow / backspace], etc)


## Examples

### Barebones

```nim
import NimSuperInput

var inp:Input = input("Input: ")

while inp.handleInput():
    discard

echo inp.text
```

### Suggestions

```nim
const suggestions = @["suggestion", "otherSuggestion"]
var inp:Input = input("Input: ")
inp.suggestions = suggestions

while inp.handleInput():
    discard

echo inp
```

### Custom displayed text

```nim
# Password example
while inp.handleInput():
    inp.displayText = ""
```

### Hinting

```nim
inp.hint = " - Hint"
while inp.handleInput():
    discard
```

## Input object Docs
```nim
Input* = object
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

    returnKey:int
```

_**`Input.suggestions`**_

Sequence of strings of all possible suggestions. 
This is also what will be filled in as auto-complete

Suggestions are only for the last word (seperated by spaces)

_**`Input.suggestionIndex`**_

What index of the `Input.suggestions` is currently being displayed

_**`Input.displayText`**_

What string is being displayed

_**`Input.hint`**_

What string is being displayed as a hint (does not work with auto complete)

_**`Input.text`**_

The current text being displayed

_**`Input.oldText`**_

The text before the latest character was pressed

_**`Input.lastKey`**_

Last key pressed 

_**`Input.position`**_

The `Input`'s position within the terminal window

_**`Input.prompt`**_
The prompt being displayed

_**`Input.index`**_

Cursor index related to `Input.text`

_**`Input.returnKey`**_

What key will be used to return the input text
Default: `keys.Enter`

## Function docs

`Input.handleInput ( display : bool ) : bool`
Returns boolean

Returns true if the return key has not been pressed.
Returns false if return key has been presesd.

Intended use case:
```nim
import NimSuperInput

var inp:Input = input()

while inp.handleInput():
    discard

echo inp.text
```

The `display` argument makes it so it automatically displays, corrects and does everything for you.
Can be disabled for a custom interface but is not recommended for non-advanced users.