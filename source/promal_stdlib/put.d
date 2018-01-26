module promal_stdlib.put;
import node;
import pegged.grammar;
import program;
import expression;
import std.stdio;

class Put: Node
{
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
    
    string eval()
    {
        for(ubyte index=1; index < this.node.children.length; index++) {
            ParseTree child = this.node.children[index];
            auto exp = new Expression(child, this.program);
            switch(exp.expr_type) {
                case 'b':
                    program.program_segment ~= exp.as_byte ~ "\n";
                    program.program_segment ~= "stdlib_putchar\n";
                    break;
                case 'w':
                    program.program_segment ~= exp.as_word ~ "\n";
                    program.program_segment ~= "stdlib_putstr\n";
                    break;
                case 'i':
                case 'r':
                default:
                    program.error("PUT only accepts arguments of type byte or string");
                    break;
            }  
        }
        
        return "";
    }
}
