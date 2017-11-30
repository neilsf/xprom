module node;

import pegged.grammar;
import program;

interface NodeInterface
{
    string eval();
}

abstract class Node: NodeInterface
{
    Program program;
    ParseTree node;
    string asmcode;

    this(ParseTree node, Program program)
    {
        this.node = node;
        this.program = program;
        this.compile();
    }
    
    void compile()
    {
	    this.asmcode = this.eval();
    }   	
    
    
    override string toString()
    {
        return this.asmcode;
    }
}
