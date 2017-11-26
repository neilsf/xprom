import std.stdio, std.array, std.conv, std.string;
import pegged.grammar;
import core.stdc.stdlib;

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

    byte[string] varlen;
    Variable[] variables;
    Const[] constants;
    short next_var_loc = 0xc00;
    
    this() {
        this.varlen["b"] = 1;
        this.varlen["w"] = 2;
        this.varlen["i"] = 3;
        this.varlen["r"] = 5;
        this.settings = ProgramSettings(0xc000, 0xcfff, 0x0801, 0x9999);
    }

    bool constExists(string id)
    {
        foreach(ref elem; this.variables) {
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

    void globalVariable(ParseTree node)
    {
		string varname;
        string vartype;
        Const constant;
        ushort uvalue;
        ushort[3] array_subscript = [1,1,1];

        varname = node.children[0].matches[0];
        vartype = node.children[1].matches[0];

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

        this.variables ~= Variable(0xc000, varname, vartype[0], array_subscript);
    }
    
    void processProgram(ParseTree node)
    {
    	auto program_id = node.children[0];
	    writeln("  /* PROGRAM "~program_id.matches[0]~" */");    	
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
        writeln(this.constants);
    	
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
