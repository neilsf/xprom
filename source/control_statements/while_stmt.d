module control_statements.while_stmt;
import node;
import pegged.grammar;
import program;
import expression;

class While_stmt: Node
{
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
    
    string eval()
    {
        string ret = "";
        string close_label, else_label;
        ret ~= program.while_stack.push() ~ "\n";
        close_label = program.while_stack.getCurrentCloseLabel();
        auto expr = new Expression(node.children[0], this.program);
        ret ~= expr.as_byte;
        ret ~= "\tPLA\n"
             ~ "\tBNE *+5\n"
             ~ "\tJMP " ~ close_label  ~ "\n";
        
        program.program_segment ~= ret;

        return "";
    }
}
