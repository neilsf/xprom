module relation;

import pegged.grammar;
import node;
import program;
import simplexp;
import std.conv;

class Relation: Node
{
    char expr_type = 'b';
    
    this(ParseTree node, Program program) { super(node, program); }

    string eval()
    {
        string ret_string = "";
        foreach(ref simplexp_node; node.children) {
			final switch(simplexp_node.name) {
				case "PROMAL.Simplexp":
				    auto se = new Simplexp(simplexp_node, this.program);
					ret_string ~= to!string(se);
					this.program.last_type = se.expr_type;
				break;
				
				case "PROMAL.Lt":
					char ltype = this.program.last_type;
                    auto se = new Simplexp(simplexp_node.children[0], this.program);
					ret_string ~= to!string(se);
					char rtype = se.expr_type;

					ret_string ~= ""; // What types to compare?
					break;
					
				case "PROMAL.Lte":
                    auto se = new Simplexp(simplexp_node.children[0], this.program);
					ret_string ~= to!string(se);
					ret_string ~= ""; // What types to compare?
					break;
					
				case "PROMAL.Neq":
                    auto se = new Simplexp(simplexp_node.children[0], this.program);
					ret_string ~= to!string(se);
					ret_string ~= ""; // What types to compare?
					break;
					
				case "PROMAL.Gt":
                    auto se = new Simplexp(simplexp_node.children[0], this.program);
					ret_string ~= to!string(se);
					ret_string ~= ""; // What types to compare?
					break;
					
				case "PROMAL.Gte":
                    auto se = new Simplexp(simplexp_node.children[0], this.program);
					ret_string ~= to!string(se);
					ret_string ~= ""; // What types to compare?
					break;
			}    				
		}    
    
        return ret_string;
    }
}
