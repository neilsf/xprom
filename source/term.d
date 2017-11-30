module term;

import pegged.grammar;
import node;
import program;
import factor;
import std.conv;

class Term:Node
{
    char expr_type;

    this(ParseTree node, Program program) { super(node, program); }
    
    string eval()
    {
        string ret_string = "";
    	char return_type;
    	
    	foreach(ref factor; node.children) {
    		final switch(factor.name) {
    			case "PROMAL.Factor":
    			    auto fact = new Factor(factor, this.program);
    				ret_string ~= to!string(fact);
	    			break;
	    			
	  			case "PROMAL.Mult":
    			
	    			break;
	    			
	  			case "PROMAL.Div":
    			
	    			break;
	  			
	  			case "PROMAL.Mod":
    			
	    			break;
	    			
	  			case "PROMAL.Lshift":
    			
	    			break;

	  			case "PROMAL.Rshift":
    			
	    			break;
    		}
    	}
    	
    	return ret_string;
    }    
}
