module procedure;

import program;
import pegged.grammar;

struct Argument {
    string name;
    char type;
}

class Procedure
{
    string id;
    Argument[] args;
    Program program;

    this(Program program) {
        this.program = program;
    }    

    void define(ParseTree node)
    {
        ubyte i = 1;
        this.id = node.children[i].matches[0];
        i++;
        while(node.children[i].name == "PROMAL.Arg_def") {
            this.args ~= Argument(node.children[i].children[1].matches[0], to!char(node.children[i].children[2].matches[0]));
            i++;
        }

        this.program.procedures ~= this;
    }    
}
