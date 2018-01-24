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
                case 'w':
                case 'i':
                
                    break;
                    
                case 'r':
                
                    break;
                    
                case 's':
                    program.program_segment ~= "stdlib.puts";
                    break;
                   
                default:
                    
                    break;
            }  
        }
        
        return "";
    }
}
