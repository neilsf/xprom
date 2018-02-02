module factor;

import pegged.grammar;
import node;
import program;
import std.conv;
import excess;
import std.stdio;
import expression;
import petscii;

class Factor: Node
{
    string as_byte;
    string as_word;
    string as_int;
    string as_real;
    
    char expr_type;
    char force_type;

    this(ParseTree node, Program program)
    {
        super(node, program);
    }
 
    string eval()
    {
        string ret_string = "";
    	ParseTree fact = this.node.children[0];
        final switch(fact.name) {
    		case "PROMAL.Charlit":
                ubyte val = fact.matches[0][1];
                this.as_byte = "\tlda #"~to!string(val)~"\npha\n";
                this.as_word = this.as_byte ~ "\tphzero\n";
                this.as_int = this.as_word ~ "\tphzero\n";

                ubyte[5] bytes = excessConvert(val);
                this.as_real = "";
                this.as_real~= "\tlda #"~to!string(bytes[0])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[1])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[2])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[3])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[4])~"\n\tpha\n";
                this.expr_type = 'b';
                break;
	    		
    		case "PROMAL.String":
                string str = fact.matches[0][1..$-1];
    			this.program.data_segment ~= 
                    "stringlit_" ~ to!string(program.stringlit_counter) ~ "\tHEX\t" ~ ascii_to_petscii_hex(str) ~ "\n";

                this.expr_type = 'w';
                this.as_word ~="\tpaddr " ~ "stringlit_" ~ to!string(program.stringlit_counter);
    			program.stringlit_counter+=1;
    			break;
    			
  			case "PROMAL.True":
  				this.as_byte =  "\tpone\n";
                this.as_word = this.as_byte ~ "\tphzero\n";
                this.as_int = this.as_word ~ "\tphzero\n";
  				ubyte[5] bytes = excessConvert(1.0);
                this.as_real = "";
                this.as_real~= "\tlda #"~to!string(bytes[0])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[1])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[2])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[3])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[4])~"\n\tpha\n";
                this.expr_type = 'b';
  				break;
  				
  			case "PROMAL.False":
  				this.as_byte =  "\tpzero\n";
                this.as_word = this.as_byte ~ "\tphzero\n";
                this.as_int = this.as_word ~ "\tphzero\n";
  				ubyte[5] bytes = excessConvert(0.0);
                this.as_real = "";
                this.as_real~= "\tlda #"~to!string(bytes[0])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[1])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[2])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[3])~"\n\tpha\n";
                this.as_real~= "\tlda #"~to!string(bytes[4])~"\n\tpha\n";
                this.expr_type = 'b';
  				break;
				
    		case "PROMAL.Not":
    			Factor operand = new Factor(fact.children[0], this.program);
                if(operand.expr_type != 'b') {
                    this.program.error("Illegal type: NOT only accepts byte type as operand.");
                }
                this.as_byte = operand.as_byte;
                this.as_byte~= "\tnotbool\n";
                this.as_word = this.as_byte ~ "\tphzero\n";
                this.as_int = this.as_word ~ "\tphzero\n";
                this.as_real = this.as_byte ~ "\tbyte2real\n";
                this.expr_type = 'b';
    			break;
    		
  			case "PROMAL.Number":
                string lit_type = this.program.guessTheType(fact.matches[0]);
                this.evalNumber(fact.matches[0], lit_type);
    			break;

			case "PROMAL.Var":
				if(this.program.constExists(fact.matches[0])) {
                    Const con = this.program.getConst(fact.matches[0]);
                    this.evalNumber(con.type == 'r' ? to!string(con.fvalue) : to!string(con.ivalue)         , to!string(con.type));
                }
                else if(this.program.idExists(fact.matches[0])) {
                    Variable variable = this.program.findVariable(fact.matches[0]);
                    final switch(variable.type) {
                        case 'b':
                            this.as_byte ="\tpbyte _"~variable.name~"\n";
                            this.as_word = this.as_byte ~ "\tphzero\n";
                            this.as_int = this.as_word ~ "\tphzero\n";
                            this.as_real = this.as_byte ~ "\tbyte2real\n";
                            this.expr_type = 'b';
                            break;
                        case 'w':
                            this.as_byte ="\tpbyte _"~variable.name~"\n";
                            this.as_word ="\tpwordvar _"~variable.name~"\n";
                            this.as_int = this.as_word ~ "\tphzero\n";
                            this.as_real = "\tword2real\n";
                            this.expr_type = 'w';
                            break;
                        case 'i':
                            this.as_byte ="\tpbyte _"~variable.name~"\n";
                            this.as_word ="\tpwordvar _"~variable.name~"\n";
                            this.as_int ="\tpintvar _"~variable.name~"\n";
                            this.expr_type = 'i';
                            break;
                        case 'r':
                            this.as_real ="\tprvar _"~variable.name~"\n";
                            this.expr_type = 'r';
                            break;
                    }
                }
				break;

            case "PROMAL.Exp":
                auto exp = new Expression(fact, this.program);
                this.as_byte = exp.as_byte;
                this.as_word = exp.as_word;
                this.as_int = exp.as_int;
                this.as_real = exp.as_real;
                this.expr_type = exp.expr_type;    
                break;
    	}
    	return ret_string;
    }

    void evalNumber(string number, string lit_type)
    {
		final switch(lit_type) {
   			case "b":
				this.as_byte = "\tpbyte #"~to!string(this.program.parseInt(number))~"\n";
                this.as_word = this.as_byte ~ "\tphzero\n";
                this.as_int = this.as_word ~ "\tphzero\n";
				this.expr_type = 'b';
				break;
						
			case "w":
                this.as_byte = "\tpbyte #<"~to!string(this.program.parseInt(number))~"\n";
				this.as_word = "\tpword #"~to!string(this.program.parseInt(number))~"\n";
                this.as_int = this.as_word ~ "\tphzero\n";
				this.expr_type = 'w';
				break;
						
			case "i":
                this.as_byte = this.as_word = "\tpword #"~to!string(this.program.parseInt(number) & 0x0000ff)~"\n";
                this.as_word = "\tpword #"~to!string(this.program.parseInt(number) & 0x00ffff)~"\n";
                this.as_int = "\tpint #"~to!string(this.program.parseInt(number))~"\n";
				this.expr_type = 'i';
				break;
						
			case "r":
				ubyte[5] bytes = excessConvert(this.program.parseFloat(number));
				foreach(b; bytes) {
					this.as_real ~= "\tpbyte #"~to!string(b)~"\n";
				}
				this.expr_type = 'r';
				break;
			}

        if(lit_type == "b" || lit_type == "w" || lit_type == "i") {
            ubyte[5] bytes = excessConvert(to!real(this.program.parseInt(number)));
            this.as_real = "";
            this.as_real~= "\tlda #"~to!string(bytes[0])~"\n\tpha\n";
            this.as_real~= "\tlda #"~to!string(bytes[1])~"\n\tpha\n";
            this.as_real~= "\tlda #"~to!string(bytes[2])~"\n\tpha\n";
            this.as_real~= "\tlda #"~to!string(bytes[3])~"\n\tpha\n";
            this.as_real~= "\tlda #"~to!string(bytes[4])~"\n\tpha\n";
        }
    }
}
