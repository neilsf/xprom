import std.stdio, std.array, std.conv, std.string;
import pegged.grammar;
import core.stdc.stdlib;
import excess;

struct Variable {
    ushort location;
    string name;
    char type;
    ushort[3] array_subscript;
}

struct Const {
	string name;
	char type;
	float fvalue;
	int ivalue;
}

class Program
{
    struct ProgramSettings {
        ushort heap_start;
        ushort heap_end;
        ushort program_start;
        ushort program_end;
    }

    ProgramSettings settings;

    byte[char] varlen;
    Variable[] variables;
    Variable[] external_variables;
    Variable[] program_data;
    Const[] constants;
    short next_var_loc = 0xc00;
    string program_segment;
    string data_segment;

    this() {
        this.varlen['b'] = 1;
        this.varlen['w'] = 2;
        this.varlen['i'] = 3;
        this.varlen['r'] = 6;
        this.settings = ProgramSettings(0xc000, 0xcfff, 0x0801, 0x9999);
    }

    bool constExists(string id)
    {
        foreach(ref elem; this.constants) {
		  		if(id == elem.name) {
		  			return true;
		  		}
    	}

    	return false;
    }

    Const getConst(string name)
    {
        foreach(elem; this.constants) {
            if(elem.name == name) {
                return elem;
            }
        }

        assert(0);
    }

    void extDecl(ParseTree node)
    {
    	string decl_type = node.children[0].name;
    	if(decl_type == "PROMAL.Var_decl") {
    		Variable v = this.parseVarDecl(node.children[0]);
    		int location = this.parseInt(node.children[1].matches[0]);
    		v.location = cast(ushort)location;
    		this.external_variables ~= v;
    	}
    	else {

    	}
    }

    Variable parseVarDecl(ParseTree node)
    {
    	string varname;
      string vartype;
      Const constant;
      ushort uvalue;
      ushort[3] array_subscript = [1,1,1];

      varname = node.children[1].matches[0];
      vartype = node.children[0].matches[0];

      for(ubyte i=2; i<=node.children.length-2; i++) {
        if(this.constExists(node.children[i].matches[0])) {
          constant = this.getConst(node.children[i].matches[0]);
          uvalue = cast(ushort)constant.ivalue;
        }
        else {
          uvalue = cast(ushort)this.parseInt(node.children[i].matches[0]);
        }
          array_subscript[i-2] = uvalue;
      }

      return Variable(0, varname, vartype[0], array_subscript);
    }

    void globalVariable(ParseTree node)
    {
      this.variables ~= this.parseVarDecl(node);
    }
    
    string getDataSegment()
    {
    	string ret = "\n*=* \"data\"\n";
    	ret ~= this.data_segment;
    	return ret;
    }
    
    string getVarSegment()
    {
    	string varsegment = "\n*=* \"globals\" virtual\n";
    	foreach(ref variable; this.variables) {
    		ubyte varlen = this.varlen[variable.type];
    		int array_len = variable.array_subscript[0] * variable.array_subscript[1] * variable.array_subscript[2];
    		varsegment ~= "_" ~ variable.name ~": .fill " ~ to!string(varlen * array_len) ~ ",0\n";
    	}

    	foreach(ref variable; this.external_variables) {
    		varsegment ~= ".label _" ~ variable.name ~" = " ~ to!string(variable.location) ~ "\n";
    	}

    	return varsegment;
    }

    void processProgram(ParseTree node)
    {
    	auto program_id = node.children[0];
	    writeln("/* PROGRAM "~program_id.matches[0]~" */");
    }

    void constDef(ParseTree node)
    {
	    	float floatval;
	    	int intval;
        string vartype;
        string id;
        string value;

        if(node.children[0].name == "PROMAL.Vartype") {
            vartype = node.children[0].matches[0];
            id = node.children[1].matches[0];
            value = node.children[2].matches[0];
        }
        else {
            id = node.children[0].matches[0];
            value = node.children[1].matches[0];
            vartype = this.guessTheType(value);
        }

    	if(vartype[0] == 'r') {
    		floatval = this.parseFloat(value);
    		intval = 0;
    	}
    	else {
    		intval = this.parseInt(value);
    		floatval = 0.0;
    	}

    	assertIdExists(id);
    	this.constants ~= Const(id, vartype[0], floatval, intval);
    }
    
    void dataDef(ParseTree node)
    {
    	string vartype = node.children[0].matches[0];
    	string id = node.children[1].matches[0];
    	real[] realdata;
    	int[] intdata;
    	assertIdExists(id);
    	ushort dataLen = 0;
    	for(ubyte i=2; i<=node.children.length-2; i++) {
    		if(node.children[i].name == "PROMAL.NL") {
    			continue;
    		}
				if(vartype[0] == 'r') {
						realdata ~= this.parseFloat(node.children[i].children[0].matches[0]);
				}
				else {
						intdata ~= this.parseInt(node.children[i].children[0].matches[0]);
				}
				dataLen+=1;
    	}
    	
    	this.program_data ~= Variable(0, id, vartype[0], [dataLen,1,1]);
    	
    	if(vartype[0] == 'w') {
      	this.data_segment ~= "_"~id~": .word ";  	
    	}
    	else {
	    	this.data_segment ~= "_"~id~": .byte ";    	
    	}

    	
    	ubyte[5] data_bytes;
    	ubyte[3] int_bytes;
    	
    	for(ubyte i=0; i<dataLen; i++) {
    		switch(vartype[0]) {
					case 'r':
						data_bytes = excessConvert(realdata[i]);
						this.data_segment ~= to!string(data_bytes[0])~","~to!string(data_bytes[1])~","~to!string(data_bytes[2])~","~to!string(data_bytes[3])~","~to!string(data_bytes[4])~",";
						break;
						
					case 'b':
					case 'w':
						this.data_segment ~= to!string(intdata[i])~",";
						break;
						
					case 'i':
						int_bytes = this.intToBin(intdata[i]);
						this.data_segment ~= to!string(int_bytes[2])~","~to!string(int_bytes[1])~","~to!string(int_bytes[0])~",";
						break;
						
					default:
						{}
						break;
				}
    	}
    	
    	this.data_segment.popBack();
    	this.data_segment~="\n";
    
    }
    
    void subDef(ParseTree node)
    {
    	/* Proc */
    	if(node.children[0].matches[0] == "proc") {
    		
    	}
    	/* Func */
    	else {
    	
    	}
    }
    
    string evalFactor(ParseTree node, ref char return_type)
    {
    	string ret_string = "";
    	ParseTree fact = node.children[0];
    	final switch(fact.name) {
    		case "PROMAL.Charlit":
    			ret_string ~= "lda #"~fact.matches[0]~"\n";
    			ret_string ~= "pha\n";
    			return_type = 'b';
	    		break;
	    		
    		case "PROMAL.String":
    			{} // TODO
    			break;
    			
  			case "PROMAL.True":
  				ret_string ~= "pone\n";
  				return_type = 'b';
  				break;
  				
  			case "PROMAL.False":
  				ret_string ~= "pzero\n";
  				return_type = 'b';
  				break;
				
    		case "PROMAL.Not":
    			{} // TODO
    			break;
    		
  			case "PROMAL.Number":
					final switch(this.guessTheType(fact.matches[0])){
			   			case "b":
							ret_string ~= "pbyte #"~to!string(this.parseInt(fact.matches[0]))~"\n";
							return_type = 'b';
							break;
							
						case "w":
							ret_string ~= "pword #"~to!string(this.parseInt(fact.matches[0]))~"\n";
							return_type = 'w';
							break;
							
						case "i":
							ret_string ~= "pint #"~to!string(this.parseInt(fact.matches[0]))~"\n";
							return_type = 'i';
							break;
							
						case "r":
							ubyte[5] bytes = excessConvert(this.parseFloat(fact.matches[0]));
							foreach(b; bytes) {
								ret_string ~= "pbyte #"~to!string(b)~"\n";
							}
							return_type = 'r';
							break;
					}
    			break;

				case "PROMAL.Var":
					if(this.constExists(fact.matches[0])) {


                    }
                    else if(this.idExists(fact.matches[0])) {
                        Variable variable = this.findVariable(fact.matches[0]);
                    }
					break;
    	
    	}
    	return ret_string;
    }
        
    
    string evalTerm(ParseTree node)
    {
    	string ret_string = "";
    	char return_type;
    	
    	foreach(ref factor; node.children) {
    		final switch(factor.name) {
    			case "PROMAL.Factor":
    				ret_string ~= this.evalFactor(factor, return_type);
	    			break;
	    			
	  			case "PROMAL.Mult":
    			
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
    	}
    	
    	return ret_string;
    }
    
    string evalSimplexp(ParseTree node)
    {
    	string ret_string = "";
    	ubyte count = 0;
    	
    	foreach(ref term; node.children) {
    		final switch(term.name) {
    			case "PROMAL.Term":
    				ret_string ~= this.evalTerm(term);		
    				break;
    				
  				case "PROMAL.Minus":
  				
						if(count == 0) { // Substract from zero
						
						}
						else { // Substract from previous Term
		    			ret_string ~= this.evalTerm(term.children[0]);
		    			ret_string ~= ""; // What types to substract?						
						}

    				break;
    				
  				case "PROMAL.Plus":
		    			ret_string ~= this.evalTerm(term.children[0]);
		    			ret_string ~= ""; // What types to add?						
    				break;
    				
    		}
    		
    		count++;
    	}
    	
    	return ret_string;
    }
    
    string evalExp(ParseTree node)
    {
    	string ret_string = "";
    
    	foreach(ref relation; node.children) {
    	
    		final switch(relation.name) {
    			case "PROMAL.Relation":
    				
    				foreach(ref simplexp; relation.children) {
    					final switch(simplexp.name) {
    						case "PROMAL.Simplexp":
    							ret_string ~= this.evalSimplexp(simplexp);
  	  						break;
    						
    						case "PROMAL.Lt":
    							ret_string ~= this.evalSimplexp(simplexp.children[0]);
    							ret_string ~= ""; // What types to compare?
	    						break;
	    						
    						case "PROMAL.Lte":
    							ret_string ~= this.evalSimplexp(simplexp.children[0]);
    							ret_string ~= ""; // What types to compare?
	    						break;
	    						
    						case "PROMAL.Neq":
    							ret_string ~= this.evalSimplexp(simplexp.children[0]);
    							ret_string ~= ""; // What types to compare?
	    						break;
	    						
    						case "PROMAL.Gt":
    							ret_string ~= this.evalSimplexp(simplexp.children[0]);
    							ret_string ~= ""; // What types to compare?
	    						break;
	    						
    						case "PROMAL.Gte":
    							ret_string ~= this.evalSimplexp(simplexp.children[0]);
    							ret_string ~= ""; // What types to compare?
	    						break;
    					}    				
    				}
    				
    				break;
    			
    			case "PROMAL.Or":
		  			ret_string ~= this.evalExp(relation.children[0]);
		  			ret_string ~= "orb\n";
    				break;
    				
  				case "PROMAL.And":
		  			ret_string ~= this.evalExp(relation.children[0]);
		  			ret_string ~= "andb\n";
    				break;
    		
  				case "PROMAL.Xor":
		  			ret_string ~= this.evalExp(relation.children[0]);
		  			ret_string ~= "xorb\n";
    				break;
    		
    		}
  		}
  		
  		return ret_string;
    }
    
    ubyte[3] intToBin(int number)
    {
    	ubyte[3] data_bytes;
    
			if(number < 0) {
					number = 16777216 + number;
				}
			
			try {
				data_bytes[0] = to!ubyte(number >> 16);
				data_bytes[1] = to!ubyte((number & 65280) >> 8);
				data_bytes[2] = to!ubyte(number & 255);
			}
			catch(Exception e) {
				writeln("Compile error: number out of range: "~to!string(number));
				exit(1);
			}
			
			return data_bytes;
    }

    float parseFloat(string strval)
    {
	    return to!float(strval);
    }

    int parseInt(string strval)
    {
	  try {
		  if(strval[0] == '$') {
				  return to!int(strval[1..$] ,16);
			  }
			  else if(strval[0] == '%') {
				  return to!int(strval[1..$] ,2);
			  }
			  else {
				  return to!int(strval);
			  }
	  } catch (std.conv.ConvException e) {
		  writeln("Syntax error: '" ~ strval ~"' is not a valid integer literal");
		  exit(1);
	  }

	  return 0;
    }

    void assertIdExists(string id)
    {
    	if(idExists(id)) {
    		writeln("Semantic error: can't redefine '" ~ id ~"'");
	    	exit(1);
    	}
    }

    Variable findVariable(string id)
    {
        foreach(ref elem; this.variables) {
    		if(id == elem.name) {
    			return elem;
    		}
    	}

    	foreach(ref elem; this.external_variables) {
    		if(id == elem.name) {
    			return elem;
    		}
    	}

        assert(0);
    }

    bool idExists(string id)
    {
    	foreach(ref elem; this.constants) {
    		if(id == elem.name) {
    			return true;
    		}
    	}

    	foreach(ref elem; this.variables) {
    		if(id == elem.name) {
    			return true;
    		}
    	}

    	foreach(ref elem; this.external_variables) {
    		if(id == elem.name) {
    			return true;
    		}
    	}

    	return false;
    }

    string guessTheType(string number)
    {
        if(number.indexOfAny(".") > -1) {
            return "r";
        }
        int numericval = this.parseInt(number);
        if(numericval < 0 ||  numericval > 65535) {
            return "i";
        }
        else if(numericval > 255) {
            return "w";
        }
        else {
            return "b";
        }
    }

    void processAst(ParseTree node)
    {
        ubyte level = 1;

        void walkAst(ParseTree node)
        {
				  //writeln("  ".replicate(level) ~ "Child name: "~node.name);
				  level +=1;

					switch(node.name) {
						case "PROMAL.Program_decl":
							this.processProgram(node);
							break;

						case "PROMAL.Const_def":
							this.constDef(node);
							break;

            case "PROMAL.Global_decl":
                this.globalVariable(node);
                break;

            case "PROMAL.Ext_decl":
            	this.extDecl(node);
            	break;
            	
          	case "PROMAL.Data_def":
          		this.dataDef(node);
            	break;
            	
          	case "PROMAL.Sub_def":
          		this.subDef(node);
            	break;

						default:
							foreach(ref child; node.children) {
								walkAst(child);
							}
						break;

					}

					level -=1;
        }

        walkAst(node);
    }
}
