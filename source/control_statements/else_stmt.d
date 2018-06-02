module control_statements.else_stmt;
import node;
import pegged.grammar;
import program;

class Else_stmt: Node
{
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
    
    string eval()
    {
        program.program_segment ~= "\tJMP " ~ program.if_stack.getCurrentCloseLabel()  ~ "\n";
        program.program_segment ~= program.if_stack.getCurrentElseLabel() ~ ":\n";
        return "";
    }
}
