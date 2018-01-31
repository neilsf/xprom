module term;

import pegged.grammar;
import node;
import program;
import factor;
import std.conv;
import std.string;
import std.stdio;

class Term: Node
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
    	
        ubyte factor_index = 0;

        ParseTree firstfactor = node.children[factor_index];
        auto ffact = new Factor(firstfactor, this.program);

        this.expr_type = ffact.expr_type;
        
        if(node.children.length == 1) {
            this.as_byte = ffact.as_byte;
            this.as_word = ffact.as_word;
            this.as_int = ffact.as_int;
            this.as_real = ffact.as_real;
        }
        
    	for(factor_index = 1; factor_index < node.children.length; factor_index++) {

            ParseTree factor = node.children[factor_index];
            Factor fact = new Factor(factor.children[0], this.program);
            fact.eval();
                        
    		final switch(factor.name) {
    				
	  			case "PROMAL.Mult":
                    this.doOperation(factor_index, fact, ffact, "mulb", "mulw", "muli", "mulr");                    
	    			break;
	    			
	  			case "PROMAL.Div":
    	       	    this.doOperation(factor_index, fact, ffact, "divb", "divw", "divi", "divr");
	    			break;
	  			
	  			case "PROMAL.Mod":
    		        this.doOperation(factor_index, fact, ffact, "modb", "modw", "modi", "modr");	
	    			break;
	    			
	  			case "PROMAL.Lshift":
                    if(this.expr_type == 'r') {
                        this.program.error("Can't do byte shift operation on real type");
                    }
    			    this.doOperation(factor_index, fact, ffact, "lshb", "lshw", "lshi", "");
	    			break;

	  			case "PROMAL.Rshift":
                    if(this.expr_type == 'r') {
                        this.program.error("Can't do byte shift operation on real type");
                    }
                    this.doOperation(factor_index, fact, ffact, "rshb", "rshw", "rshi", "");
	    			break;
    		}
            factor_index++;
    	}

        switch(this.expr_type) {
            case 'b':
                this.as_word = this.as_byte ~ "pzero\n";
                this.as_int = this.as_word ~ "pzero\n";
                this.as_real = this.as_byte ~ "byte2real\n";
            break;

            case 'w':
                this.as_int = this.as_word ~ "pzero\n";
                this.as_real = this.as_byte ~ "word2real\n";
            break;

            case 'i':
                this.as_real = this.as_byte ~ "int2real\n";
            break;

            default: {} break;

        }

    	return ret_string;
    }    

    void doOperation(ubyte factor_index, ref Factor fact, ref Factor ffact, string byte_op, string word_op, string int_op, string real_op)
    {
        char result_type;
                    
        if(factor_index == 1) {

            result_type = this.getHigherType(fact.expr_type, ffact.expr_type);

            final switch(result_type) {
                case 'b':
                    this.as_byte ~= ffact.as_byte;
                    this.as_byte ~= fact.as_byte;
                    this.as_byte ~= byte_op ~ "\n";
                    this.as_word ~= this.as_byte ~ "phzero\n";
                    this.as_int ~= this.as_word ~ "phzero\n";
                    this.as_real ~= this.as_byte ~ "byte2real\n";
                break;

                case 'w':
                    this.as_word ~= ffact.as_word;
                    this.as_word ~= fact.as_word;
                    this.as_word ~= word_op ~ "\n";
                    this.as_int ~= this.as_word ~ "phzero\n";
                    this.as_real ~= this.as_word ~ "word2real\n";
                    this.expr_type = 'w';
                break;

                case 'i':
                    this.as_int ~= ffact.as_int;
                    this.as_int ~= fact.as_int;
                    this.as_int ~= int_op ~ "\n";
                    this.as_real~= this.as_int ~ "int2real\n";
                    this.expr_type = 'i';
                break;

                case 'r':
                    this.as_real ~= ffact.as_real;
                    this.as_real ~= fact.as_real;
                    this.as_real ~= real_op ~ "\n";
                    this.expr_type = 'r';
                break;
            }
                        
        }
        else {

            if(type_precedence.indexOf(fact.expr_type) >= type_precedence.indexOf(this.expr_type)) {
                result_type = fact.expr_type;
            }
            else {
                result_type = this.expr_type;
            }

            final switch(result_type) {
                case 'b':
                    this.as_byte ~= fact.as_byte;
                    this.as_byte ~= byte_op ~ "\n";
                break;

                case 'w':
                    this.as_word ~= fact.as_word;
                    this.as_word ~= word_op ~ "\n";
                    this.as_int ~= this.as_word ~ "phzero\n";
                    this.as_real ~= this.as_word ~ "word2real\n";
                    this.expr_type = 'w';
                break;

                case 'i':
                    this.as_int ~= fact.as_int;
                    this.as_int ~= int_op ~ "\n";
                    this.as_real~= this.as_int ~ "int2real\n";
                    this.expr_type = 'i';
                break;

                case 'r':
                    this.as_real ~= ffact.as_real;
                    this.as_real ~= fact.as_real;
                    this.as_real ~= real_op ~ "\n";
                    this.expr_type = 'r';
                break;
            }
        }
    }
}
