import std.stdio, std.array, std.conv, std.string;
import pegged.grammar;
import core.stdc.stdlib;
import excess;
import expression;
import procedure;
import promal_stdlib.put;
import promal_stdlib.p_out;

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
    Procedure[] procedures;
    Const[] constants;
    short next_var_loc = 0xc00;
    ushort stringlit_counter = 0;
    string program_segment;
    string data_segment;
    
    char last_type;

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
    	string ret;
    	ret ~= this.data_segment;
    	return ret;
    }
    
    string getVarSegment()
    {
    	string varsegment;
    	foreach(ref variable; this.variables) {
    		ubyte varlen = this.varlen[variable.type];
    		int array_len = variable.array_subscript[0] * variable.array_subscript[1] * variable.array_subscript[2];
    		varsegment ~= "_" ~ variable.name ~"\tDS.B " ~ to!string(varlen * array_len) ~ "\n";
    	}

    	foreach(ref variable; this.external_variables) {
    		varsegment ~= "_" ~ variable.name ~"\tEQU " ~ to!string(variable.location) ~ "\n";
    	}

    	return varsegment;
    }

    void processProgram(ParseTree node)
    {
    	auto program_id = node.children[0];
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

    void assignment(ParseTree node)
    {
        string identifier = node.children[0].matches[0];
        if(!this.idExists(identifier)) {
            this.error(identifier~" is not defined"); 
        }

        if(constExists(identifier)) {
            this.error(identifier~" is a constant");             
        }

        Variable v = this.findVariable(identifier);
        
        auto exp = new Expression(node.children[1], this);

        final switch(v.type) {
            case 'b':
                this.program_segment ~= exp.as_byte;
                this.program_segment ~= "\tplb2var _" ~v.name~"\n";
            break;

            case 'w':
                this.program_segment ~= exp.as_word;
                this.program_segment ~= "\tplw2var _" ~v.name~"\n";
            break;

            case 'i':
                this.program_segment ~= exp.as_int;
                this.program_segment ~= "\tpli2var _" ~v.name~"\n";
            break;

            case 'r':
                this.program_segment ~= exp.as_real;
                this.program_segment ~= "\tplr2var _" ~v.name~"\n";
            break;

        }
    }

    void sub_def(ParseTree node)
    {
        string type = node.matches[0];
        if(type == "proc") {
            auto proc = new Procedure(this);
            proc.define(node);
        }
    }

    void stdlib_call(ParseTree node)
    {
        string procname = node.matches[0];
        switch(procname) {
            case "put":
                auto dispatcher = new Put(node, this);            
                break;

            case "out":
                auto dispatcher = new Out(node, this);            
                break;
            
            default:
                this.error("Stdlib procedure doesn't exist: "~procname);
                break;
        }
        
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
				this.error("Compile error: number out of range: "~to!string(number));
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
		  this.error("Syntax error: '" ~ strval ~"' is not a valid integer literal");
	  }

	  return 0;
    }

    void assertIdExists(string id)
    {
    	if(idExists(id)) {
    		this.error("Semantic error: can't redefine '" ~ id ~"'");
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

    void error(string error_message)
    {
        writeln(error_message);
        exit(1);
    }

    void processAst(ParseTree node)
    {
        ubyte level = 1;

        void walkAst(ParseTree node)
        {
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

                    case "PROMAL.Assignment":
                        this.assignment(node);
                        break;

                    case "PROMAL.Stdlib_call":
                        this.stdlib_call(node);
                        break;
              
                    case "PROMAL.End":
                        this.program_segment~="\trts\n";
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
