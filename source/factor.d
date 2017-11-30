module factor;

import pegged.grammar;
import node;
import program;
import std.conv;
import excess;

class Factor:Node
{
    char expr_type;

    this(ParseTree node, Program program) { super(node, program); }
    
    string eval()
    {
        string ret_string = "";
    	ParseTree fact = this.node.children[0];
    	final switch(fact.name) {
    		case "PROMAL.Charlit":
    			ret_string ~= "lda #"~fact.matches[0]~"\n";
    			ret_string ~= "pha\n";
    			this.expr_type = 'b';
	    		break;
	    		
    		case "PROMAL.String":
    			{} // TODO
    			break;
    			
  			case "PROMAL.True":
  				ret_string ~= "pone\n";
  				this.expr_type = 'b';
  				break;
  				
  			case "PROMAL.False":
  				ret_string ~= "pzero\n";
  				this.expr_type = 'b';
  				break;
				
    		case "PROMAL.Not":
    			{} // TODO
    			break;
    		
  			case "PROMAL.Number":
				final switch(this.program.guessTheType(fact.matches[0])){
		   			case "b":
						ret_string ~= "pbyte #"~to!string(this.program.parseInt(fact.matches[0]))~"\n";
						this.expr_type = 'b';
						break;
						
					case "w":
						ret_string ~= "pword #"~to!string(this.program.parseInt(fact.matches[0]))~"\n";
						this.expr_type = 'w';
						break;
						
					case "i":
						ret_string ~= "pint #"~to!string(this.program.parseInt(fact.matches[0]))~"\n";
						this.expr_type = 'i';
						break;
						
					case "r":
						ubyte[5] bytes = excessConvert(this.program.parseFloat(fact.matches[0]));
						foreach(b; bytes) {
							ret_string ~= "pbyte #"~to!string(b)~"\n";
						}
						this.expr_type = 'r';
						break;
					}
    			break;

				case "PROMAL.Var":
					if(this.program.constExists(fact.matches[0])) {


                    }
                    else if(this.program.idExists(fact.matches[0])) {
                        Variable variable = this.program.findVariable(fact.matches[0]);
                    }
					break;
    	
    	}
    	return ret_string;
    }
}
