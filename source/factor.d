module factor;

import pegged.grammar;
import node;
import program;
import std.conv;
import excess;

class Factor: Node
{
    string as_byte;
    string as_word;
    string as_int;
    string as_real;
    
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
    	ParseTree fact = this.node.children[0];
    	final switch(fact.name) {
    		case "PROMAL.Charlit":
                ubyte val = fact.matches[0][1];
                this.as_byte = "lda #"~to!string(val)~"\npha\n";
                this.as_word = this.as_byte ~ "phzero\n";
                this.as_int = this.as_word ~ "phzero\n";

                ubyte[5] bytes = excessConvert(val);
                this.as_real = "";
                this.as_real~= "lda #"~to!string(bytes[0])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[1])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[2])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[3])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[4])~"\npha\n";
                this.expr_type = 'b';
                break;
	    		
    		case "PROMAL.String":
    			{} // TODO
    			break;
    			
  			case "PROMAL.True":
  				this.as_byte =  "pone\n";
                this.as_word = this.as_byte ~ "phzero\n";
                this.as_int = this.as_word ~ "phzero\n";
  				ubyte[5] bytes = excessConvert(1.0);
                this.as_real = "";
                this.as_real~= "lda #"~to!string(bytes[0])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[1])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[2])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[3])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[4])~"\npha\n";
                this.expr_type = 'b';
  				break;
  				
  			case "PROMAL.False":
  				this.as_byte =  "pzero\n";
                this.as_word = this.as_byte ~ "phzero\n";
                this.as_int = this.as_word ~ "phzero\n";
  				ubyte[5] bytes = excessConvert(0.0);
                this.as_real = "";
                this.as_real~= "lda #"~to!string(bytes[0])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[1])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[2])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[3])~"\npha\n";
                this.as_real~= "lda #"~to!string(bytes[4])~"\npha\n";
  				break;
				
    		case "PROMAL.Not":
    			{} // TODO
    			break;
    		
  			case "PROMAL.Number":
                string lit_type = this.program.guessTheType(fact.matches[0]);
				final switch(lit_type) {
		   			case "b":
						this.as_byte = "pbyte #"~to!string(this.program.parseInt(fact.matches[0]))~"\n";
                        this.as_word = this.as_byte ~ "phzero\n";
                        this.as_int = this.as_word ~ "phzero\n";
						this.expr_type = 'b';
						break;
						
					case "w":
						this.as_word = "pword #"~to!string(this.program.parseInt(fact.matches[0]))~"\n";
                        this.as_int = this.as_word ~ "phzero\n";
						this.expr_type = 'w';
						break;
						
					case "i":
						ret_string ~= "pint #"~to!string(this.program.parseInt(fact.matches[0]))~"\n";
						this.expr_type = 'i';
						break;
						
					case "r":
						ubyte[5] bytes = excessConvert(this.program.parseFloat(fact.matches[0]));
						foreach(b; bytes) {
							this.as_real ~= "pbyte #"~to!string(b)~"\n";
						}
						this.expr_type = 'r';
						break;
					}

                if(lit_type == "b" || lit_type == "w" || lit_type == "i") {
                    ubyte[5] bytes = excessConvert(to!real(this.program.parseInt(fact.matches[0])));
                    this.as_real = "";
                    this.as_real~= "lda #"~to!string(bytes[0])~"\npha\n";
                    this.as_real~= "lda #"~to!string(bytes[1])~"\npha\n";
                    this.as_real~= "lda #"~to!string(bytes[2])~"\npha\n";
                    this.as_real~= "lda #"~to!string(bytes[3])~"\npha\n";
                    this.as_real~= "lda #"~to!string(bytes[4])~"\npha\n";
                }
    			break;

				case "PROMAL.Var":
					if(this.program.constExists(fact.matches[0])) {

                    }
                    else if(this.program.idExists(fact.matches[0])) {
                        Variable variable = this.program.findVariable(fact.matches[0]);
                        final switch(variable.type) {
                            case 'b':
                                ret_string~="pbyte _"~variable.name~"\n";
                                break;
                            case 'w':
                                ret_string~="pword _"~variable.name~"\n";
                                break;
                            case 'i':
                                ret_string~="pint _"~variable.name~"\n";
                                break;
                            case 'r':
                                ret_string~="prvar _"~variable.name~"\n";
                                break;
                        }
                    }
					break;
    	
    	}
    	return ret_string;
    }
}
