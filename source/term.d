module term;

import pegged.grammar;
import node;
import program;
import factor;
import std.conv;
import std.string;

class Term: Node
{
    char expr_type;

    string as_byte = "";
    string as_word = "";
    string as_int = "";
    string as_real = "";

    this(ParseTree node, Program program) { super(node, program); }

    string type_precedence = "bwir";    
    
    string eval()
    {
        string ret_string = "";
    	
        ubyte factor_index = 0;

        ref factor = note.children[factor_index];
        auto ffact = new Factor(factor, this.program);
        ffact.eval();
        this.expr_type = ffact.expr_type;
        
    	for(factor_index = 1; factor_index < node.children.length; factor_index++) {
            ref factor = node.children[i];
    		final switch(factor.name) {
    				
	  			case "PROMAL.Mult":

                    ref fact = new Factor(factor.children[factor_index], this.program);
                    fact.eval();

                    char result_type;
                    
                    if(factor_index == 1) {

                        if(type_precedence.indexOf(fact.expr_type) >= type_precedence.indefOx(ffact.expr_type) {
                            result_type = fact.expr_type;
                        }
                        else {
                            result_type = ffact.expr_type;
                        }

                        final switch(result_type) {
                            case 'b':
                                this.as_byte ~= ffact.as_byte;
                                this.as_byte ~= fact.as_byte;
                                this.as_byte ~= "mulb\n";
                                this.as_word ~= this.as_byte ~ "phzero\n";
                                this.as_int ~= this.as_word ~ "phzero\n";
                                this.as_real ~= this.as_byte ~ "byte2real\n";
                            break;

                            case 'w':
                                this.as_word ~= ffact.as_word;
                                this.as_word ~= fact.as_word;
                                this.as_word ~= "mulw\n";
                                this.as_int ~= this.as_word ~ "phzero\n";
                                this.as_byte ~= this.as_word ~ "pla\n";
                                this.as_real ~= this.as_word ~ "word2real\n";
                                this.expr_type = 'w';
                            break;

                            case 'i':
                                this.as_int ~= ffact.as_int;
                                this.as_int ~= fact.as_int;
                                this.as_int ~= "muli\n";
                                this.as_word~= this.as_int ~ "pla\n";
                                this.as_byte~= this.as_word ~ "pla\n";
                                this.as_real~= this.as_int ~ "int2real\n";
                                this.expr_type = 'i';
                            break;

                            case 'r':
                                this.as_real ~= ffact.as_real;
                                this.as_real ~= fact.as_real;
                                this.as_real ~= "mulr\n";
                                this.as_int ~= this.as_real ~ "real2int\n";
                                this.as_word ~= this.as_real ~ "real2word\n";
                                this.as_byte ~= this.as_real ~ "real2byte\n";
                                this.expre_type = 'r';
                            break;
                        }
                        
                    }
                    else {

                        if(type_precedence.indexOf(fact.expr_type) >= type_precedence.indefOx(this.expr_type) {
                            result_type = fact.expr_type;
                        }
                        else {
                            result_type = this.expr_type;
                        }

                        final switch(result_type) {
                            case 'b':
                                this.as_byte ~= fact.as_byte;
                                this.as_byte ~= "mulb\n";
                            break;

                            case 'w':
                                this.as_word ~= ffact.as_word;
                                this.as_word ~= fact.as_word;
                                this.as_word ~= "mulw\n";
                                this.as_int ~= this.as_word ~ "phzero\n";
                                this.as_byte ~= this.as_word ~ "pla\n";
                                this.as_real ~= this.as_word ~ "word2real\n";
                                this.expr_type = 'w';
                            break;

                            case 'i':
                                this.as_int ~= ffact.as_int;
                                this.as_int ~= fact.as_int;
                                this.as_int ~= "muli\n";
                                this.as_word~= this.as_int ~ "pla\n";
                                this.as_byte~= this.as_word ~ "pla\n";
                                this.as_real~= this.as_int ~ "int2real\n";
                                this.expr_type = 'i';
                            break;

                            case 'r':
                                this.as_real ~= ffact.as_real;
                                this.as_real ~= fact.as_real;
                                this.as_real ~= "mulr\n";
                                this.as_int ~= this.as_real ~ "real2int\n";
                                this.as_word ~= this.as_real ~ "real2word\n";
                                this.as_byte ~= this.as_real ~ "real2byte\n";
                                this.expre_type = 'r';
                            break;
                        }

                    }
                    
                    
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
            factor_index++;
    	}
    	
    	return ret_string;
    }    
}
