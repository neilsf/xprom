module relation;

import pegged.grammar;
import node;
import program;
import simplexp;
import std.conv;
import std.stdio;

class Relation: Node
{
    char expr_type;

    string as_byte = "";
    string as_word = "";
    string as_int = "";
    string as_real = "";
    
    this(ParseTree node, Program program) { super(node, program); }

    string eval()
    {
        string ret_string = "";
        Simplexp se_left, se_right;
        string relation;
                        
        se_left = new Simplexp(node.children[0], this.program);
        if(node.children.length == 1) {
            this.as_byte = se_left.as_byte;
            this.as_word = se_left.as_word;
            this.as_int = se_left.as_int;
            this.as_real = se_left.as_real;
            this.expr_type = se_left.expr_type;
            return "";
        }

        se_right = new Simplexp(node.children[1].children[0], this.program);
        relation = node.children[1].name;

        this.expr_type = 'b';
        char result_type = this.getHigherType(se_left.expr_type, se_right.expr_type);

        string rel_type;
        
        final switch(relation) {      
			case "PROMAL.Lt":
                rel_type = "lt";        
                break;
					
			case "PROMAL.Lte":
                rel_type = "lte";    
				break;
					
			case "PROMAL.Neq":
                rel_type = "neq";    
				break;
					
			case "PROMAL.Gt":
                rel_type = "gt";                    
				break;
					
			case "PROMAL.Gte":
                rel_type = "gte";
				break;
		}

        this._buildRelation(rel_type, result_type, se_left, se_right);

        this.as_word = this.as_byte ~ "phzero\n";
        this.as_int = this.as_word ~ "phzero\n";
        this.as_real = this.as_byte ~ "byte2real\n";
    
        return ret_string;
    }

    void _buildRelation(string rel_type, char expr_type, Simplexp se_left, Simplexp se_right)
    {
        final switch(expr_type) {
            case 'b':
               this.as_byte = se_left.as_byte ~ se_right.as_byte ~ "cmpb"~rel_type~"\n"; 
            break;
            case 'w':
               this.as_byte = se_left.as_word ~ se_right.as_word ~ "cmpw"~rel_type~"\n"; 
            break;
            case 'i':
               this.as_byte = se_left.as_int ~ se_right.as_int ~ "cmpi"~rel_type~"\n"; 
            break;
            case 'r':
               this.as_byte = se_left.as_real ~ se_right.as_real ~ "cmpr"~rel_type~"\n"; 
            break;
        }
    }
}
