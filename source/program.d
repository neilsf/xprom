
struct Variable {
    short location;
    string name;
    char type;
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
    short next_var_loc = 0xc00;

    this() {
        this.varlen["b"] = 1;
        this.varlen["w"] = 2;
        this.varlen["i"] = 3;
        this.varlen["f"] = 5;
        this.settings = ProgramSettings(0xc000, 0xcfff, 0x0801, 0x9999);
    }

    void declareVariable(string name, char type ) {

    }
}
