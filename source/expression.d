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
    char expr_type;
    string as_byte = "";
    string as_word = "";
    string as_int = "";
    string as_real = "";
    
    this(ParseTree node, Program program)
    { 
        super(node, program);
    }

    string eval()
    {
    	string ret_string = "";

        auto rel0 = new Relation(this.node.children[0], this.program);
        this.expr_type = rel0.expr_type;        

        if(this.node.children.length == 1) {
            this.as_byte = rel0.as_byte;
            this.as_word = rel0.as_word;
            this.as_int = rel0.as_int;
            this.as_real = rel0.as_real;
            return "";
        }

        if(this.expr_type != 'b') {
            this._type_error();
        }

        this.as_byte = rel0.as_byte;

        for(ubyte index=1; index < this.node.children.length; index++) {
            ParseTree child = this.node.children[index];
            switch(child.name) {
    			
    			case "PROMAL.Or":
    			    auto rel = new Relation(child.children[0], this.program);
    	  			if(rel.expr_type != 'b') {
                        this._type_error();
                    }
    	  			this.as_byte ~= rel.as_byte ~ "\torb\n";
    				break;
    				
    			case "PROMAL.And":
    			    auto rel = new Relation(child.children[0], this.program);
    	  			if(rel.expr_type != 'b') {
                        this._type_error();
                    }
    	  			this.as_byte ~= rel.as_byte ~ "\tandb\n";
    				break;
    		
    			case "PROMAL.Xor":
    			    auto rel = new Relation(child.children[0], this.program);
    	  			if(rel.expr_type != 'b') {
                        this._type_error();
                    }
    	  			this.as_byte ~= rel.as_byte ~ "\txorb\n";
    				break;
    				
    			default:
    			    writeln(child.matches[0] ~ " not found.");
    			    exit(1);
    			    break;
    		
    		}
  		}

        this.as_word = this.as_byte ~ "\tpzero\n";
        this.as_int = this.as_word ~ "\tpzero\n";
        this.as_real = this.as_byte ~ "\tbyte2real\n";
  		
  		return ret_string;
    }
   
    void _type_error()
    {
        this.program.error("Only byte types can make part of a logical expression");
    }

    override string toString()
    {
        string ret;                 
        final switch(this.expr_type) {
            case 'b': ret = this.as_byte; break;
            case 'w':
             ret = this.as_word;
             break;
            case 'i': ret = this.as_int; break;
            case 'r': ret = this.as_real; break;
        }
        return ret;
    }
}

