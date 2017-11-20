import std.stdio, std.file, std.array;

import pegged.grammar;
import program;

mixin(grammar(`
PROMAL:
    Program < Program_decl (Const_def / Global_decl / Ext_decl / Data_def / Sub_def)* "begin" NL Stmt+ "end" NL WS?

    Program_decl < "program" WS id "own"? "export"? NL
    Const_def < "const" WS Vartype WS id WS? "=" WS? Number NL
    Global_decl < "global" WS Vartype WS id ("[" Number "]")? NL
    Ext_decl < "ext" WS (Var_decl / Asm_decl) WS ("at" (Number / id))? NL
    Var_decl < Vartype WS id "[" (Number / id)? "]"
    Asm_decl < "asm" WS ("func" / "proc") WS Vartype WS id
    Data_def < "data" WS Vartype WS id "[]"? WS? "=" WS? Data_member (WS? "," WS? Data_member)* NL
    Data_member < String / Number

    Sub_def < ("proc" / ("func" WS Vartype) ) WS id NL ("arg" WS Vartype WS id NL)* (Vartype id NL)* (Const_def / ("own" WS Global_decl) / Ext_decl / Data_def / ("list" WS Exp? NL))* "begin" NL Stmt+ "end" NL

    Stmt < (Assignment / Proc_call / If_stmt / Choose_stmt / Repeat_stmt / For_stmt / While_stmt / ("refuge" WS Number) / ("escape" WS Number) / "break" / "next" / ("return" WS Exp?) / "nothing" ) NL

    Assignment < id (":<" / ":>")? "=" Exp
    Proc_call < "call" WS id (Exp ("," Exp)*)?
    Func_call < id WS? (WS? "(" WS? Exp WS? (Exp WS? "," WS?)* WS? ")" WS?)?
    If_stmt < "if" WS Exp NL Stmt+ ("else" WS ("if" WS Exp NL)? Stmt+)* "end if" NL
    Choose_stmt < "choose" (WS? Exp)? NL ("case" WS Exp NL Stmt+ "end case" NL)+ ("else" NL Stmt+)? "end choose" NL
    Repeat_stmt < "repeat" NL Stmt+ "until" Exp NL
    For_stmt < "for" WS id WS? "=" WS? Exp WS "to" WS Exp NL Stmt+ "end for" NL
    While_stmt < "while" WS Exp NL Stmt+ "end while" NL

    Exp < Relation (("and" / "or" / "xor") Relation)*
    Relation < Simplexp (("<" / "<=" / "<>" / ">=" / ">") Simplexp)?
    Simplexp < "-"? Term (("+" / "-") Term)*
    Term < Factor (("*" / "/" / "%" / "<<" / ">>") Factor)*
    Factor <- ("'" Char "'") / String / "true" / "false" / ("not" Factor) / Number / ("#"? Var) / Func_call / ("(" WS? Exp WS? ")")
    Var < id ("[" Exp "]")?
    Cast < ":<" / ":>" / ":-" / ":+" / ":." / "@<" / "@-" / "@+" / "@."

    Keyword <- "end" / "program" / "own" / "export" / "con" / "byte"/ "word" / "int" / "real" / "ext" / "global" / "data" / "proc" / "func" / "begin" / "end" / "asm" / "at" / "arg" / "list" / "if" / "choose" / "while" / "repeat" / "for" / "else" / "return" / "nothing" / "refuge" / "escape" / "break" / "next" / "case" / "else" / "until" / "and" / "or" / "xor" / "true" / "false" / "not" / "call"
    Number <~ Scientific / Floating / Integer / Hexa
    String <~ doublequote (!doublequote Char)* doublequote
    Char    <~ backslash ( doublequote  # '\' Escapes
                        / quote
                        / backslash
                        / [bfnrt]
                        / 'x' Hexa
                        )
                        / . # Or any char, really

    Scientific <~ Floating ( ('e' / 'E' ) Integer )?
    Floating   <~ Integer ('.' Unsigned )?
    Unsigned   <~ [0-9]+
    Integer    <~ Sign? Unsigned
    Hexa       <~ "$" [0-9a-fA-F]+
    Sign       <- '-' / '+'

    Vartype    <- "byte" / "word" / "int" / "real"

    WS <~ (space / eol / Comment)*
    Comment <~ "//" (!eol .)* eol
    id <~ !Keyword [a-zA-Z_] [a-zA-Z_0-9]*
    EOI <- !.

    NL <- ('\r' / '\n' / '\r\n')+
    Spacing <- :(' ' / '\t')*
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

    byte level = 1;

    void processAst(ParseTree node) {
        writeln("  ".replicate(level) ~ "Child name: "~node.name);
        level +=1;
        foreach(ref child; node.children) {
            processAst(child);
        }
        level -=1;
    }

    Program program = new Program;
    processAst(ast);
}

