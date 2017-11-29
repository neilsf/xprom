import std.stdio, std.file, std.array;
import program;
import promalg;

void main()
{
    File infile = File("test.prm", "r");
    string source = "";
    while(!infile.eof){
        source = source ~ infile.readln();
    }

    //writeln(source);

    auto ast = PROMAL(source);
    writeln(ast);
    writeln("Name: "~ast.name);
    writeln("Success? " ~ (ast.successful == true ? "Yes" : "No"));

    Program program = new Program;
    program.processAst(ast);		writeln(program.getDataSegment());
    writeln(program.getVarSegment());

}

