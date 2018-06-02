module control_statements.if_stmt;
import node;
import pegged.grammar;
import program;
import expression;

class If_stmt: Node
{
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
    
    string eval()
    {
        string ret = "";
        string close_label, else_label;
        ret ~= program.if_stack.push() ~ "\n";
        close_label = program.if_stack.getCurrentCloseLabel();
        else_label = program.if_stack.getCurrentElseLabel();
        auto expr = new Expression(node.children[0], this.program);
        ret ~= expr.as_byte;
        ret ~= "\tPLA\n"
             ~ "\tBNE *+5\n"
             ~ "\tIFCONST " ~ else_label ~ "\n"
             ~ "\tJMP " ~ else_label  ~ "\n"   
             ~ "\tELSE\n"
             ~ "\tJMP " ~ close_label  ~ "\n"
             ~ "\tENDIF\n";
        
        program.program_segment ~= ret;

        return "";
    }
}
