import std.stdio, std.file;

import pegged.grammar;
import program;

mixin(grammar(`
PROMAL:
    Program < Program_decl WS (Const_def / Global_decl / Ext_decl / Data_def / Sub_def)* "begin" WS Stmt* "end" WS?

    Program_decl < "program" WS id "own"? "export"?
    Const_def < "const" WS Vartype WS id WS? "=" WS? Number WS
    Global_decl < "global" WS Vartype WS id ("[" Number "]")? WS
    Ext_decl < "ext" WS (Var_decl / Asm_decl) WS ("at" (Number / id))? WS
    Var_decl < Vartype WS id "[" (Number / id)? "]"
    Asm_decl < "asm" WS ("func" / "proc") WS Vartype WS id
    Data_def < "data" WS Vartype WS id "[]"? WS? "=" WS? Data_member (WS? "," WS? Data_member)* WS
    Data_member < String / Number

    Sub_def < ("proc" / ("func" WS Vartype) ) WS id WS ("arg" WS Vartype WS id WS)* (Vartype id WS)* (Const_def / ("own" WS Global_decl) / Ext_decl / Data_def / ("list" WS Exp? WS))* "begin" WS Stmt+ "end" WS

    Stmt < (Assignment / Proc_call / If_stmt / Choose_stmt / Repeat_stmt / For_stmt / While_stmt / ("refuge" WS Number) / ("escape" WS Number) / "break" / "next" / ("return" WS Exp?) / "nothing" ) WS

    Assignment < id WS? (":<" / ":>")? WS? "=" WS? Exp
    Proc_call < id (WS? Exp (WS? "," WS? Exp)*)?
    If_stmt < "if" WS Exp WS Stmt+ ("else" WS ("if" WS Exp WS)? Stmt+)* "end if" WS
    Choose_stmt < "choose" (WS? Exp)? WS ("case" WS Exp WS Stmt+ "end case" WS)+ ("else" WS Stmt+)? "end choose" WS
    Repeat_stmt < "repeat" WS Stmt+ "until" Exp WS
    For_stmt < "for" WS id WS? "=" WS? Exp WS "to" WS Exp WS Stmt+ "end for" WS
    While_stmt < "while" WS Exp WS Stmt+ "end while" WS

    Exp < Relation (WS? ("and" / "or" / "xor") WS? Relation)*
    Relation < Simplexp (WS? ("<" / "<=" / "<>" / ">=" / ">") WS? Simplexp)
    Simplexp < "-"? Term (WS? ("+" / "-") WS? Term)*
    Term < Factor (WS? ("*" / "/" / "%" / "<<" / ">>") WS? Factor)*
    Factor < ("'" Char "'") / ('"' Char '"') / "true" / "false" / ("not" Factor) / Number / ("#"? Var) / (id WS? (WS? "(" WS? Exp WS? (Exp WS? "," WS?)* WS? ")" WS?)?) / ("(" WS? Exp WS? ")")
    Var < id ("[" Exp "]")?
    Cast < ":<" / ":>" / ":-" / ":+" / ":." / "@<" / "@-" / "@+" / "@."

    WS <~ (space / eol / Comment)*
    Comment <~ "//" (!eol .)* eol
    id <~ !Keyword [a-zA-Z_] [a-zA-Z_0-9]*
    nl <- "\n"
    EOI <- !.

    Keyword <- "program" / "own" / "export" / "con" / "byte" / "word" / "int / "real" / "ext" / "global" / "data" / "proc" / "func" / "begin" / "end" / "asm" / "at" / "arg" / "list" / "if" / "choose" / "while" / "repeat" / "for" / "else" / "return" / "nothing" / "refuge" / "escape" / "break" / "next" / "case" / "else" / "until" / "and" / "or" / "xor" / "true" / "false" / "not"
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

    Vartype    <- "byte" / "word" / "int" / "real"
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

