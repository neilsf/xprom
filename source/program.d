import std.stdio, std.array, std.conv, std.string;
import pegged.grammar;
import core.stdc.stdlib;

struct Variable {
    short location;
    string name;
    char type;
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

    void declareVariable(string name, char type )
    {
		
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
    
    	writeln(" FOUND CONST DEF ");	
			string vartype = node.children[0].matches[0];
			string id = node.children[1].matches[0];
			string value = node.children[2].matches[0];
    	if(vartype == "real") {
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
