import std.stdio, std.file, std.array, std.string, std.getopt;
import core.stdc.stdlib;
import program;
import pegged.grammar;

/*
 * Grammar declaration for PROMAL
 * This can be moved outside the
 * main module later
 */

mixin(grammar(`
PROMAL:
    Program < Program_decl (Const_def / Global_decl / Ext_decl / Data_def / Sub_def)* "begin" NL Stmt+ "end" NL? WS*

    Program_decl < "program" WS id "own"? "export"? NL
    Const_def < "const" (WS Vartype)? WS id WS? "=" WS? Number NL
    Global_decl < "global" WS Vartype WS id ("[" (Number / id) ("," (Number / id))* "]")? NL
    Ext_decl < "ext" WS (Var_decl / Asm_decl) WS ("at" (Number / id))? NL
    Var_decl < Vartype WS id ("[" (Number / id) ("," (Number / id))* "]")?
    Asm_decl < "asm" WS ("func" / "proc") WS Vartype WS id
    Data_def < "data" WS Vartype WS id "[]"? WS? "=" WS? Data_member (WS? "," WS? Data_member)* NL
    Data_member < String / Number

    Sub_def < ("proc" / ("func" WS Vartype) ) WS id NL (Arg_def)* (Vartype id NL)* (Const_def / ("own" WS Global_decl) / Ext_decl / Data_def / ("list" WS Exp? NL))* "begin" NL Stmt+ "end" NL

    Stmt < (Assignment / Proc_call / Stdlib_call / If_stmt / Choose_stmt / Repeat_stmt / For_stmt / While_stmt / ("refuge" WS Number) / ("escape" WS Number) / "break" / "next" / ("return" WS Exp?) / "nothing" ) NL

    Assignment < id (":<" / ":>")? "=" Exp
    Arg_def < "arg" WS Vartype WS id NL
    Proc_call < "call" WS id (Exp ("," Exp)*)?
    Stdlib_call < Stdlib_procname (Exp ("," Exp)*)?
    Func_call < id WS? (WS? "(" WS? Exp WS? (Exp WS? "," WS?)* WS? ")" WS?)?
    If_stmt < "if" WS Exp NL Stmt+ ("else" WS ("if" WS Exp NL)? Stmt+)* "end if" NL
    Choose_stmt < "choose" (WS? Exp)? NL ("case" WS Exp NL Stmt+ "end case" NL)+ ("else" NL Stmt+)? "end choose" NL
    Repeat_stmt < "repeat" NL Stmt+ "until" Exp NL
    For_stmt < "for" WS id WS? "=" WS? Exp WS "to" WS Exp NL Stmt+ "end for" NL
    While_stmt < "while" WS Exp NL Stmt+ "end while" NL

    Exp < Relation (Or / And / Xor)*
    Or < "or" Relation
    And < "and" Relation
    Xor < "xor" Relation
    Relation < Simplexp (Lt / Lte / Neq / Gte / Gt)?
    Lt < "<" Simplexp
    Lte < "<=" Simplexp
    Neq < "<>" Simplexp
    Gte < ">=" Simplexp
    Gt < ">" Simplexp

    Simplexp < (Minus / Term) (Plus / Minus)*

    Minus < "-" Term
    Plus < "+" Term

    Term < Factor (Mult / Div / Mod / Lshift / Rshift)*

    Mult < "*" Factor
    Div < "/" Factor
    Mod < "%" Factor
    Lshift < "<<" Factor
    Rshift < ">>" Factor

    Factor <- Charlit / String / True / False / Not / Number / ("#"? Var) / Func_call / ("(" WS? Exp WS? ")")

    True < "true"
    False < "false"
    Not < "not" Factor

    Var < id ("[" Exp "]")?
    Cast < ":<" / ":>" / ":-" / ":+" / ":." / "@<" / "@-" / "@+" / "@."

	Charlit < "'" Char "'"

    Stdlib_procname <- "abort" / "blkmov" / "close" / "curset" / "dir" / "edline" / "exit" / "fill" / "jsr" / "mlget" / "movstr" / "open" / "output" / "outputf" / "put" / "putblkf" / "putf" / "redirect" / "rename" / "zapfile"
    Keyword <- "end" / "program" / "own" / "export" / "con" / "byte"/ "word" / "int" / "real" / "ext" / "global" / "data" / "proc" / "func" / "begin" / "end" / "asm" / "at" / "arg" / "list" / "if" / "choose" / "while" / "repeat" / "for" / "else" / "return" / "nothing" / "refuge" / "escape" / "break" / "next" / "case" / "else" / "until" / "and" / "or" / "xor" / "true" / "false" / "not" / "call"
    Number <~ Scientific / Floating / Integer / Hexa
    String <~ doublequote (!doublequote Char)* doublequote
    Char    <~ backslash ( doublequote  # '\' Escapes
                        / quote
                        / backslash
                        / [bfnrt]
                        / 'x' Hexa
                        )
                        / . # Or any char

    Scientific <~ Floating ( ('e' / 'E' ) Integer )?
    Floating   <~ Integer ('.' Unsigned )?
    Unsigned   <~ [0-9]+
    Integer    <~ Sign? Unsigned
    Hexa       <~ "$" [0-9a-fA-F]+
    Sign       <- '-' / '+'
    
    Vartype    <- "byte" / "word" / "int" / "real"

    WS <~ (space / eol / Comment)*
    Comment <~ "//" (!eol .)* eol
    id <~ !Keyword !Stdlib_procname [a-zA-Z_] [a-zA-Z_0-9]*
    EOI <- !.

    NL <- ('\r' / '\n' / '\r\n')+
    Spacing <- :(' ' / '\t')*
`));

/*
 * Application entry point
 */

void main(string[] args)
{
    string filename = args[1];

    File infile;
    
    try {
        infile = File(filename, "r");
    }
    catch(Exception e) {
        stderr.writeln("Failed to open source file (" ~ filename ~ ")");
        exit(1);
    }
    
    string source = "";
    while(!infile.eof){
        source = source ~ infile.readln();
    }

    auto ast = PROMAL(source);

    /* TODO remove */
    
    writeln(ast);
    writeln("Name: "~ast.name);
    writeln("Success? " ~ (ast.successful == true ? "Yes" : "No"));

    Program program = new Program;
    program.processAst(ast);
    writeln(program.program_segment);
    writeln(program.getDataSegment());
    writeln(program.getVarSegment());
    writeln(program.procedures);
}

