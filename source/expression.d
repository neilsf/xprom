module expression;

import pegged.grammar;
import node;
import program;
import relation;
import simplexp;
import std.conv;
import std.stdio;
import core.stdc.stdlib;

class Expression: Node
{
    this(ParseTree node, Program program) { super(node, program); }

    string eval()
    {
    	string ret_string = "";
    
    	foreach(ref child; this.node.children) {
    	
    		switch(child.name) {
    			
    			case "PROMAL.Relation":
    				auto rel = new Relation(child, this.program);
    				ret_string ~= to!string(rel);
    				break;
    			
    			case "PROMAL.Or":
    			    auto rel = new Relation(child.children[0], this.program);
		  			ret_string ~= to!string(rel);
		  			ret_string ~= "orb\n";
    				break;
    				
  				case "PROMAL.And":
    			    auto rel = new Relation(child.children[0], this.program);
		  			ret_string ~= to!string(rel);
		  			ret_string ~= "andb\n";
    				break;
    		
  				case "PROMAL.Xor":
    			    auto rel = new Relation(child.children[0], this.program);
		  			ret_string ~= to!string(rel);
		  			ret_string ~= "xorb\n";
    				break;
    				
				default:
				    writeln(child.matches[0] ~ " not found.");
				    exit(1);
				    break;
    		
    		}
  		}
  		
  		return ret_string;
    }
}

