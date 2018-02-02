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

    string as_byte = "";
    string as_int = "";
    string as_word = "";
    string as_real = "";
        
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
    
    string eval()
    {
        string ret_string = "";
    	ubyte count = 0;

        if(this.node.children[0].name == "PROMAL.Term") {

            auto term0 = new Term(this.node.children[0], this.program);
            term0.eval();            
            this.as_byte = term0.as_byte;
            this.as_word = term0.as_word;
            this.as_int = term0.as_int;
            this.as_real = term0.as_real;
            this.expr_type = term0.expr_type;
        }
        else if(this.node.children[0].name == "PROMAL.Minus") {
            auto term0 = new Term(this.node.children[0].children[0], this.program);
            term0.eval();      
            this.as_byte = term0.as_byte ~= "\tnegbyte\n";
            this.as_word = term0.as_word ~= "\tnegword\n";
            this.as_int = term0.as_int ~= "\tnegint\n";
            this.as_real = term0.as_real ~= "\tnegreal\n";
            this.expr_type = term0.expr_type;
        }

        ubyte term_index;
    	
    	for(term_index = 1; term_index < this.node.children.length; term_index++) {
    	    ParseTree term = this.node.children[term_index];

            Term t = new Term(term.children[0], this.program);
            t.eval();

            this.expr_type = this.getHigherType(t.expr_type, this.expr_type);
                
    		switch(term.name) {
    				
  				case "PROMAL.Minus":
                    this.as_byte ~= t.as_byte ~ "\tsubb\n";
                    this.as_word ~= t.as_word ~ "\tsubw\n";
                    this.as_int ~= t.as_int ~ "\tsubi\n";
                    this.as_real ~= t.as_real ~ "\tsubr\n";
                    break;
    				
			    case "PROMAL.Plus":
				    this.as_byte ~= t.as_byte ~ "\taddb\n";
                    this.as_word ~= t.as_word ~ "\taddw\n";
                    this.as_int ~= t.as_int ~ "\taddi\n";
                    this.as_real ~= t.as_real ~ "\taddr\n";
			        break;
			        
		        default:
		            writeln(term.name ~":"~ term.matches[0]);
		            exit(1);
		            break;
    		}
    	}
    	
    	return ret_string;
    }
}
