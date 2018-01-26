# The XPROM standard library

The XPROM standard library (stdlib) is similar to the PROMAL standard library, and contains a few predefined procedures and functions. You don't have to include the stdlib in your source program, the XPROM compiler will automatically include it in the compiled program if necessary.

As in PROMAL, you can call stdlib functions and procedures in the same manner as other routines, however, most stdlib routines can be called with a **variable number and type of arguments**.

## The stdlib routines reference

The following section provides the detailed description for each stdlib routine.

### PUT
(procedure)

Usage: `put item [,item ...]`

Outputs one ore more strings or characters to the display. PUT accepts one or more arguments, each of them has to be of type WORD (a pointer to a string) or BYTE (a single character).

#### Examples

`put "Hello World", 13`

The above example outputs the string "Hello World" and the carriage return character.

```
program example put
word hellostr
begin
    hellostr = "Hello World"
    put "My example is: ", hellostr, 13
end
```

#### Notes

- You cannot use PUT to display numeric values. Please see OUTPUT.
