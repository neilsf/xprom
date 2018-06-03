module control_statements.endwhile_stmt;
import node;
import pegged.grammar;
import program;

class Endwhile_stmt: Node
{
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
    
    string eval()
    {
        program.program_segment ~= "\tJMP " ~ program.while_stack.getCurrentOpenLabel() ~ "\n";
        program.program_segment ~= program.while_stack.pop() ~ "\n";
        return "";
    }
}
