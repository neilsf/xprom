module control_statements.endif_stmt;
import node;
import pegged.grammar;
import program;

class Endif_stmt: Node
{
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
    
    string eval()
    {
        program.program_segment ~= program.if_stack.pop() ~ "\n";
        return "";
    }
}
