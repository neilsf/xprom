module simplexp;

import pegged.grammar;
import node;
import program;
import term;
import std.conv;
import std.stdio;
import core.stdc.stdlib;

class Simplexp: Node
{
    char expr_type;
    char force_type;

    this(ParseTree node, Program program, char force_type)
    {
        this.force_type = force_type;
        super(node, program);
    }
    
    string eval()
    {
        string ret_string = "";
    	ubyte count = 0;
    	
    	foreach(ref term; node.children) {
    	
    		switch(term.name) {
    			case "PROMAL.Term":
        			auto term_output = new Term(term, this.program);
    				ret_string ~= to!string(term_output);		
    				break;
    				
  				case "PROMAL.Minus":
  				
					if(count == 0) { // Substract from zero
					
					}
					else { // Substract from previous Term
						auto term_output = new Term(term.children[0], this.program);
    	    			ret_string ~= to!string(term_output);
    	    			ret_string ~= ""; // What types to substract?						
					}

    				break;
    				
			    case "PROMAL.Plus":
				    auto term_output = new Term(term.children[0], this.program);
        			ret_string ~= to!string(term_output);    		
			        break;
			        
		        default:
		            writeln(term.name ~":"~ term.matches[0]);
		            exit(1);
		            break;
    		}
    		
    		count++;
    	}
    	
    	return ret_string;
    }
}
