module promal_stdlib.put;
import node;
import pegged.grammar;
import program;
import expression;

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
                    program.program_segment ~= "stdlib_putchar "~exp.as_byte;
                    break;
                case 'w':
                    program.program_segment ~= "stdlib_putstr "~exp.as_word;
                    break;
                case 'i':
                case 'r':
                default:
                    program.error("PUT only accepts arguments of type byte or string");
                    return "";
                    break;
            }  
        }
        
        return "";
    }
}
