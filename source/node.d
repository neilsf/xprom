module node;

import pegged.grammar;
import program;
import std.string;

interface NodeInterface
{
    string eval();
}

abstract class Node: NodeInterface
{
    Program program;
    ParseTree node;
    string asmcode;

    string type_precedence = "bwir"; 

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

    char getHigherType(char type1, char type2)
    {
        if(this.type_precedence.indexOf(type1) >= this.type_precedence.indexOf(type2)) {
            return type1;
        }
        else {
            return type2;
        }
    }    
    
    override string toString()
    {
        return this.asmcode;
    }
}
