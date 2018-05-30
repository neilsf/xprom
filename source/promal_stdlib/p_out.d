module promal_stdlib.p_out;
import node;
import pegged.grammar;
import program;
import expression;
import std.stdio;

class Out: Node
{
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
    
    string eval()
    {
        
        ParseTree child = this.node.children[1];
        auto exp = new Expression(child, this.program);
        switch(exp.expr_type) {
            case 'b':
                program.program_segment ~= exp.as_byte;
                program.program_segment ~= "\tstdlib_printb\n";
                break;
            case 'w':
                program.program_segment ~= exp.as_word ~"\n";
                program.program_segment ~= "\tstdlib_printw\n";
                break;
            case 'i':
                program.program_segment ~= exp.as_int ~"\n";
                program.program_segment ~= "\tstdlib_printi\n";
                break;
            case 'r':
                program.program_segment ~= exp.as_real ~"\n";
                program.program_segment ~= "\tstdlib_printr\n";
                break;
            default:
                program.error("OUT only accepts arguments of type byte, word, int or real");
                break;
        }  
        
        
        return "";
    }
}
