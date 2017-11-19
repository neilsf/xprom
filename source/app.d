import std.stdio, std.file;

import pegged.grammar;
import program;

mixin(grammar(`
PROMAL:
    Program < Program_decl WS (Const_def / Global_decl / Ext_decl / Data_def)* "begin" WS "end" WS?
    Program_decl < "program" WS id "own"? "export"?
    Const_def < "const" WS ("byte" / "word" / "int" / "real") WS id WS? "=" WS? Number WS
    Global_decl < "global" WS ("byte" / "word" / "int" / "real") WS id ("[" Number "]")? WS
    Ext_decl < "ext" WS (Var_decl / Asm_decl) WS ("at" (Number / id))? WS
    Var_decl < ("byte" / "word" / "int" / "real") WS id "[" (Number / id)? "]"
    Asm_decl < "asm" WS ("func" / "proc") WS ("byte" / "word" / "int" / "real") WS id
    Data_def < "data" WS ("byte" / "word" / "int" / "real") WS id "[]"? WS? "=" WS? Data_member (WS? "," WS? Data_member)* WS
    Data_member < String / Number

    Factor < ("'" Char "'") / ('"' Char '"') / "true" / "false" / ("not" Factor) / Number / ("#"? Var)
    Var < id ("[" Exp "]")?
    Exp < [a-z]+
    Cast < ":<" / ":>" / ":-" / ":+" / ":." / "@<" / "@-" / "@+" / "@."

    WS <~ (space / eol / Comment)*
    Comment <~ "//" (!eol .)* eol
    id  <~ [a-zA-Z_] [a-zA-Z_0-9]*
    nl <- "\n"
    EOI <- !.

    Number <~ Scientific / Floating / Integer / Hexa
    String <~ :doublequote Char* :doublequote
    Char   <~ backslash doublequote
            / backslash backslash
            / backslash [bfnrt]
            / backslash Hexa
            / (!doublequote .)

    Scientific <~ Floating ( ('e' / 'E' ) Integer )?
    Floating   <~ Integer ('.' Unsigned )?
    Unsigned   <~ [0-9]+
    Integer    <~ Sign? Unsigned
    Hexa       <~ "$" [0-9a-fA-F]+
    Sign       <- '-' / '+'
`));



void main()
{
    File infile = File("test.prm", "r");
    string source = "";
    while(!infile.eof){
        source = source ~ infile.readln();
    }

    writeln(source);

    auto ast = PROMAL(source);
writeln(ast);
    writeln("Name: "~ast.name);
    writeln("Success? " ~ (ast.successful == true ? "Yes" : "No"));

    void processAst(ParseTree node) {
        writeln("Child name: "~node.name);
        foreach(ref child; node.children) {
            processAst(child);
        }
    }

    Program program = new Program;
    processAst(ast);
}

