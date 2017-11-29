module promalg;

import pegged.grammar;

struct GenericPROMAL(TParseTree)
{
    import std.functional : toDelegate;
    import pegged.dynamic.grammar;
    static import pegged.peg;
    struct PROMAL
    {
    enum name = "PROMAL";
    static ParseTree delegate(ParseTree)[string] before;
    static ParseTree delegate(ParseTree)[string] after;
    static ParseTree delegate(ParseTree)[string] rules;
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    static this()
    {
        rules["Program"] = toDelegate(&Program);
        rules["Program_decl"] = toDelegate(&Program_decl);
        rules["Const_def"] = toDelegate(&Const_def);
        rules["Global_decl"] = toDelegate(&Global_decl);
        rules["Ext_decl"] = toDelegate(&Ext_decl);
        rules["Var_decl"] = toDelegate(&Var_decl);
        rules["Asm_decl"] = toDelegate(&Asm_decl);
        rules["Data_def"] = toDelegate(&Data_def);
        rules["Data_member"] = toDelegate(&Data_member);
        rules["Sub_def"] = toDelegate(&Sub_def);
        rules["Stmt"] = toDelegate(&Stmt);
        rules["Assignment"] = toDelegate(&Assignment);
        rules["Proc_call"] = toDelegate(&Proc_call);
        rules["Func_call"] = toDelegate(&Func_call);
        rules["If_stmt"] = toDelegate(&If_stmt);
        rules["Choose_stmt"] = toDelegate(&Choose_stmt);
        rules["Repeat_stmt"] = toDelegate(&Repeat_stmt);
        rules["For_stmt"] = toDelegate(&For_stmt);
        rules["While_stmt"] = toDelegate(&While_stmt);
        rules["Exp"] = toDelegate(&Exp);
        rules["Or"] = toDelegate(&Or);
        rules["And"] = toDelegate(&And);
        rules["Xor"] = toDelegate(&Xor);
        rules["Relation"] = toDelegate(&Relation);
        rules["Lt"] = toDelegate(&Lt);
        rules["Lte"] = toDelegate(&Lte);
        rules["Neq"] = toDelegate(&Neq);
        rules["Gte"] = toDelegate(&Gte);
        rules["Gt"] = toDelegate(&Gt);
        rules["Simplexp"] = toDelegate(&Simplexp);
        rules["Minus"] = toDelegate(&Minus);
        rules["Plus"] = toDelegate(&Plus);
        rules["Term"] = toDelegate(&Term);
        rules["Mult"] = toDelegate(&Mult);
        rules["Div"] = toDelegate(&Div);
        rules["Mod"] = toDelegate(&Mod);
        rules["Lshift"] = toDelegate(&Lshift);
        rules["Rshift"] = toDelegate(&Rshift);
        rules["Factor"] = toDelegate(&Factor);
        rules["True"] = toDelegate(&True);
        rules["False"] = toDelegate(&False);
        rules["Not"] = toDelegate(&Not);
        rules["Var"] = toDelegate(&Var);
        rules["Cast"] = toDelegate(&Cast);
        rules["Charlit"] = toDelegate(&Charlit);
        rules["Keyword"] = toDelegate(&Keyword);
        rules["Number"] = toDelegate(&Number);
        rules["String"] = toDelegate(&String);
        rules["Char"] = toDelegate(&Char);
        rules["Scientific"] = toDelegate(&Scientific);
        rules["Floating"] = toDelegate(&Floating);
        rules["Unsigned"] = toDelegate(&Unsigned);
        rules["Integer"] = toDelegate(&Integer);
        rules["Hexa"] = toDelegate(&Hexa);
        rules["Sign"] = toDelegate(&Sign);
        rules["Vartype"] = toDelegate(&Vartype);
        rules["WS"] = toDelegate(&WS);
        rules["Comment"] = toDelegate(&Comment);
        rules["id"] = toDelegate(&id);
        rules["EOI"] = toDelegate(&EOI);
        rules["NL"] = toDelegate(&NL);
        rules["Spacing"] = toDelegate(&Spacing);
    }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p)
        {
            ParseTree result;

            if (name in before)
            {
                result = before[name](p);
                if (result.successful)
                    return result;
            }

            result = r(p);
            if (result.successful || name !in after)
                return result;

            result = after[name](p);
            return result;
        }

        static ParseTree hooked(string input)
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(name,rule; dg.rules)
        {
            if (name != "Spacing")
                rules[name] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s)
    {
		import std.algorithm : startsWith;
        return s.startsWith("PROMAL.");
    }
    mixin decimateTree;

    static TParseTree Program(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Program_decl, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_def, Spacing), pegged.peg.wrapAround!(Spacing, Global_decl, Spacing), pegged.peg.wrapAround!(Spacing, Ext_decl, Spacing), pegged.peg.wrapAround!(Spacing, Data_def, Spacing), pegged.peg.wrapAround!(Spacing, Sub_def, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("begin"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), "PROMAL.Program")(p);
        }
        else
        {
            if (auto m = tuple(`Program`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Program_decl, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_def, Spacing), pegged.peg.wrapAround!(Spacing, Global_decl, Spacing), pegged.peg.wrapAround!(Spacing, Ext_decl, Spacing), pegged.peg.wrapAround!(Spacing, Data_def, Spacing), pegged.peg.wrapAround!(Spacing, Sub_def, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("begin"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), "PROMAL.Program"), "Program")(p);
                memo[tuple(`Program`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Program(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Program_decl, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_def, Spacing), pegged.peg.wrapAround!(Spacing, Global_decl, Spacing), pegged.peg.wrapAround!(Spacing, Ext_decl, Spacing), pegged.peg.wrapAround!(Spacing, Data_def, Spacing), pegged.peg.wrapAround!(Spacing, Sub_def, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("begin"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), "PROMAL.Program")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Program_decl, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_def, Spacing), pegged.peg.wrapAround!(Spacing, Global_decl, Spacing), pegged.peg.wrapAround!(Spacing, Ext_decl, Spacing), pegged.peg.wrapAround!(Spacing, Data_def, Spacing), pegged.peg.wrapAround!(Spacing, Sub_def, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("begin"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), "PROMAL.Program"), "Program")(TParseTree("", false,[], s));
        }
    }
    static string Program(GetName g)
    {
        return "PROMAL.Program";
    }

    static TParseTree Program_decl(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("program"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("own"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("export"), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Program_decl")(p);
        }
        else
        {
            if (auto m = tuple(`Program_decl`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("program"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("own"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("export"), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Program_decl"), "Program_decl")(p);
                memo[tuple(`Program_decl`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Program_decl(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("program"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("own"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("export"), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Program_decl")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("program"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("own"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("export"), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Program_decl"), "Program_decl")(TParseTree("", false,[], s));
        }
    }
    static string Program_decl(GetName g)
    {
        return "PROMAL.Program_decl";
    }

    static TParseTree Const_def(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("const"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Const_def")(p);
        }
        else
        {
            if (auto m = tuple(`Const_def`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("const"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Const_def"), "Const_def")(p);
                memo[tuple(`Const_def`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Const_def(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("const"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Const_def")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("const"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Const_def"), "Const_def")(TParseTree("", false,[], s));
        }
    }
    static string Const_def(GetName g)
    {
        return "PROMAL.Const_def";
    }

    static TParseTree Global_decl(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("global"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Global_decl")(p);
        }
        else
        {
            if (auto m = tuple(`Global_decl`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("global"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Global_decl"), "Global_decl")(p);
                memo[tuple(`Global_decl`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Global_decl(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("global"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Global_decl")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("global"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Global_decl"), "Global_decl")(TParseTree("", false,[], s));
        }
    }
    static string Global_decl(GetName g)
    {
        return "PROMAL.Global_decl";
    }

    static TParseTree Ext_decl(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("ext"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Var_decl, Spacing), pegged.peg.wrapAround!(Spacing, Asm_decl, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("at"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Ext_decl")(p);
        }
        else
        {
            if (auto m = tuple(`Ext_decl`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("ext"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Var_decl, Spacing), pegged.peg.wrapAround!(Spacing, Asm_decl, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("at"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Ext_decl"), "Ext_decl")(p);
                memo[tuple(`Ext_decl`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Ext_decl(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("ext"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Var_decl, Spacing), pegged.peg.wrapAround!(Spacing, Asm_decl, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("at"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Ext_decl")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("ext"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Var_decl, Spacing), pegged.peg.wrapAround!(Spacing, Asm_decl, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("at"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Ext_decl"), "Ext_decl")(TParseTree("", false,[], s));
        }
    }
    static string Ext_decl(GetName g)
    {
        return "PROMAL.Ext_decl";
    }

    static TParseTree Var_decl(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "PROMAL.Var_decl")(p);
        }
        else
        {
            if (auto m = tuple(`Var_decl`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "PROMAL.Var_decl"), "Var_decl")(p);
                memo[tuple(`Var_decl`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Var_decl(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "PROMAL.Var_decl")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Number, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "PROMAL.Var_decl"), "Var_decl")(TParseTree("", false,[], s));
        }
    }
    static string Var_decl(GetName g)
    {
        return "PROMAL.Var_decl";
    }

    static TParseTree Asm_decl(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("asm"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("func"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("proc"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), "PROMAL.Asm_decl")(p);
        }
        else
        {
            if (auto m = tuple(`Asm_decl`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("asm"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("func"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("proc"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), "PROMAL.Asm_decl"), "Asm_decl")(p);
                memo[tuple(`Asm_decl`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Asm_decl(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("asm"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("func"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("proc"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), "PROMAL.Asm_decl")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("asm"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("func"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("proc"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing)), "PROMAL.Asm_decl"), "Asm_decl")(TParseTree("", false,[], s));
        }
    }
    static string Asm_decl(GetName g)
    {
        return "PROMAL.Asm_decl";
    }

    static TParseTree Data_def(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("data"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("[]"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Data_member, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Data_member, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Data_def")(p);
        }
        else
        {
            if (auto m = tuple(`Data_def`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("data"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("[]"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Data_member, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Data_member, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Data_def"), "Data_def")(p);
                memo[tuple(`Data_def`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Data_def(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("data"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("[]"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Data_member, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Data_member, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Data_def")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("data"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("[]"), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Data_member, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Data_member, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Data_def"), "Data_def")(TParseTree("", false,[], s));
        }
    }
    static string Data_def(GetName g)
    {
        return "PROMAL.Data_def";
    }

    static TParseTree Data_member(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "PROMAL.Data_member")(p);
        }
        else
        {
            if (auto m = tuple(`Data_member`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "PROMAL.Data_member"), "Data_member")(p);
                memo[tuple(`Data_member`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Data_member(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "PROMAL.Data_member")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, String, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), "PROMAL.Data_member"), "Data_member")(TParseTree("", false,[], s));
        }
    }
    static string Data_member(GetName g)
    {
        return "PROMAL.Data_member";
    }

    static TParseTree Sub_def(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("proc"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("func"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing)), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("arg"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_def, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("own"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Global_decl, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Ext_decl, Spacing), pegged.peg.wrapAround!(Spacing, Data_def, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("list"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Exp, Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("begin"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Sub_def")(p);
        }
        else
        {
            if (auto m = tuple(`Sub_def`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("proc"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("func"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing)), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("arg"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_def, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("own"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Global_decl, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Ext_decl, Spacing), pegged.peg.wrapAround!(Spacing, Data_def, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("list"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Exp, Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("begin"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Sub_def"), "Sub_def")(p);
                memo[tuple(`Sub_def`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sub_def(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("proc"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("func"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing)), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("arg"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_def, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("own"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Global_decl, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Ext_decl, Spacing), pegged.peg.wrapAround!(Spacing, Data_def, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("list"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Exp, Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("begin"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Sub_def")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("proc"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("func"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing)), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("arg"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Vartype, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Const_def, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("own"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Global_decl, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, Ext_decl, Spacing), pegged.peg.wrapAround!(Spacing, Data_def, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("list"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Exp, Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("begin"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Sub_def"), "Sub_def")(TParseTree("", false,[], s));
        }
    }
    static string Sub_def(GetName g)
    {
        return "PROMAL.Sub_def";
    }

    static TParseTree Stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Assignment, Spacing), pegged.peg.wrapAround!(Spacing, Proc_call, Spacing), pegged.peg.wrapAround!(Spacing, If_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Choose_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Repeat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, For_stmt, Spacing), pegged.peg.wrapAround!(Spacing, While_stmt, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("refuge"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("escape"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("break"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("next"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("return"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Exp, Spacing))), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("nothing"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Assignment, Spacing), pegged.peg.wrapAround!(Spacing, Proc_call, Spacing), pegged.peg.wrapAround!(Spacing, If_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Choose_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Repeat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, For_stmt, Spacing), pegged.peg.wrapAround!(Spacing, While_stmt, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("refuge"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("escape"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("break"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("next"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("return"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Exp, Spacing))), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("nothing"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Stmt"), "Stmt")(p);
                memo[tuple(`Stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Assignment, Spacing), pegged.peg.wrapAround!(Spacing, Proc_call, Spacing), pegged.peg.wrapAround!(Spacing, If_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Choose_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Repeat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, For_stmt, Spacing), pegged.peg.wrapAround!(Spacing, While_stmt, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("refuge"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("escape"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("break"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("next"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("return"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Exp, Spacing))), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("nothing"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Assignment, Spacing), pegged.peg.wrapAround!(Spacing, Proc_call, Spacing), pegged.peg.wrapAround!(Spacing, If_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Choose_stmt, Spacing), pegged.peg.wrapAround!(Spacing, Repeat_stmt, Spacing), pegged.peg.wrapAround!(Spacing, For_stmt, Spacing), pegged.peg.wrapAround!(Spacing, While_stmt, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("refuge"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("escape"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Number, Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("break"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("next"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("return"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, Exp, Spacing))), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("nothing"), Spacing)), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Stmt"), "Stmt")(TParseTree("", false,[], s));
        }
    }
    static string Stmt(GetName g)
    {
        return "PROMAL.Stmt";
    }

    static TParseTree Assignment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":>"), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), "PROMAL.Assignment")(p);
        }
        else
        {
            if (auto m = tuple(`Assignment`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":>"), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), "PROMAL.Assignment"), "Assignment")(p);
                memo[tuple(`Assignment`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Assignment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":>"), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), "PROMAL.Assignment")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":>"), Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), "PROMAL.Assignment"), "Assignment")(TParseTree("", false,[], s));
        }
    }
    static string Assignment(GetName g)
    {
        return "PROMAL.Assignment";
    }

    static TParseTree Proc_call(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("call"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), Spacing))), Spacing))), "PROMAL.Proc_call")(p);
        }
        else
        {
            if (auto m = tuple(`Proc_call`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("call"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), Spacing))), Spacing))), "PROMAL.Proc_call"), "Proc_call")(p);
                memo[tuple(`Proc_call`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Proc_call(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("call"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), Spacing))), Spacing))), "PROMAL.Proc_call")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("call"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), Spacing))), Spacing))), "PROMAL.Proc_call"), "Proc_call")(TParseTree("", false,[], s));
        }
    }
    static string Proc_call(GetName g)
    {
        return "PROMAL.Proc_call";
    }

    static TParseTree Func_call(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing))), "PROMAL.Func_call")(p);
        }
        else
        {
            if (auto m = tuple(`Func_call`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing))), "PROMAL.Func_call"), "Func_call")(p);
                memo[tuple(`Func_call`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Func_call(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing))), "PROMAL.Func_call")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("("), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(","), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(")"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing))), Spacing))), "PROMAL.Func_call"), "Func_call")(TParseTree("", false,[], s));
        }
    }
    static string Func_call(GetName g)
    {
        return "PROMAL.Func_call";
    }

    static TParseTree If_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end if"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.If_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`If_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end if"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.If_stmt"), "If_stmt")(p);
                memo[tuple(`If_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree If_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end if"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.If_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("if"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end if"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.If_stmt"), "If_stmt")(TParseTree("", false,[], s));
        }
    }
    static string If_stmt(GetName g)
    {
        return "PROMAL.If_stmt";
    }

    static TParseTree Choose_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("choose"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("case"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end case"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end choose"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Choose_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Choose_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("choose"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("case"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end case"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end choose"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Choose_stmt"), "Choose_stmt")(p);
                memo[tuple(`Choose_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Choose_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("choose"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("case"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end case"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end choose"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Choose_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("choose"), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing)), Spacing)), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("case"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end case"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), Spacing)), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("else"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing))), Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end choose"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Choose_stmt"), "Choose_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Choose_stmt(GetName g)
    {
        return "PROMAL.Choose_stmt";
    }

    static TParseTree Repeat_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("repeat"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("until"), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Repeat_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`Repeat_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("repeat"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("until"), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Repeat_stmt"), "Repeat_stmt")(p);
                memo[tuple(`Repeat_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Repeat_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("repeat"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("until"), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Repeat_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("repeat"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("until"), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.Repeat_stmt"), "Repeat_stmt")(TParseTree("", false,[], s));
        }
    }
    static string Repeat_stmt(GetName g)
    {
        return "PROMAL.Repeat_stmt";
    }

    static TParseTree For_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("for"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("to"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end for"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.For_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`For_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("for"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("to"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end for"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.For_stmt"), "For_stmt")(p);
                memo[tuple(`For_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree For_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("for"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("to"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end for"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.For_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("for"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, WS, Spacing)), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("to"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end for"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.For_stmt"), "For_stmt")(TParseTree("", false,[], s));
        }
    }
    static string For_stmt(GetName g)
    {
        return "PROMAL.For_stmt";
    }

    static TParseTree While_stmt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("while"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end while"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.While_stmt")(p);
        }
        else
        {
            if (auto m = tuple(`While_stmt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("while"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end while"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.While_stmt"), "While_stmt")(p);
                memo[tuple(`While_stmt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree While_stmt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("while"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end while"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.While_stmt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("while"), Spacing), pegged.peg.wrapAround!(Spacing, WS, Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing), pegged.peg.oneOrMore!(pegged.peg.wrapAround!(Spacing, Stmt, Spacing)), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("end while"), Spacing), pegged.peg.wrapAround!(Spacing, NL, Spacing)), "PROMAL.While_stmt"), "While_stmt")(TParseTree("", false,[], s));
        }
    }
    static string While_stmt(GetName g)
    {
        return "PROMAL.While_stmt";
    }

    static TParseTree Exp(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Or, Spacing), pegged.peg.wrapAround!(Spacing, And, Spacing), pegged.peg.wrapAround!(Spacing, Xor, Spacing)), Spacing))), "PROMAL.Exp")(p);
        }
        else
        {
            if (auto m = tuple(`Exp`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Or, Spacing), pegged.peg.wrapAround!(Spacing, And, Spacing), pegged.peg.wrapAround!(Spacing, Xor, Spacing)), Spacing))), "PROMAL.Exp"), "Exp")(p);
                memo[tuple(`Exp`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Exp(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Or, Spacing), pegged.peg.wrapAround!(Spacing, And, Spacing), pegged.peg.wrapAround!(Spacing, Xor, Spacing)), Spacing))), "PROMAL.Exp")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Relation, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Or, Spacing), pegged.peg.wrapAround!(Spacing, And, Spacing), pegged.peg.wrapAround!(Spacing, Xor, Spacing)), Spacing))), "PROMAL.Exp"), "Exp")(TParseTree("", false,[], s));
        }
    }
    static string Exp(GetName g)
    {
        return "PROMAL.Exp";
    }

    static TParseTree Or(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("or"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.Or")(p);
        }
        else
        {
            if (auto m = tuple(`Or`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("or"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.Or"), "Or")(p);
                memo[tuple(`Or`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Or(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("or"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.Or")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("or"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.Or"), "Or")(TParseTree("", false,[], s));
        }
    }
    static string Or(GetName g)
    {
        return "PROMAL.Or";
    }

    static TParseTree And(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("and"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.And")(p);
        }
        else
        {
            if (auto m = tuple(`And`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("and"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.And"), "And")(p);
                memo[tuple(`And`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree And(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("and"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.And")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("and"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.And"), "And")(TParseTree("", false,[], s));
        }
    }
    static string And(GetName g)
    {
        return "PROMAL.And";
    }

    static TParseTree Xor(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("xor"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.Xor")(p);
        }
        else
        {
            if (auto m = tuple(`Xor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("xor"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.Xor"), "Xor")(p);
                memo[tuple(`Xor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Xor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("xor"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.Xor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("xor"), Spacing), pegged.peg.wrapAround!(Spacing, Relation, Spacing)), "PROMAL.Xor"), "Xor")(TParseTree("", false,[], s));
        }
    }
    static string Xor(GetName g)
    {
        return "PROMAL.Xor";
    }

    static TParseTree Relation(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Lt, Spacing), pegged.peg.wrapAround!(Spacing, Lte, Spacing), pegged.peg.wrapAround!(Spacing, Neq, Spacing), pegged.peg.wrapAround!(Spacing, Gte, Spacing), pegged.peg.wrapAround!(Spacing, Gt, Spacing)), Spacing))), "PROMAL.Relation")(p);
        }
        else
        {
            if (auto m = tuple(`Relation`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Lt, Spacing), pegged.peg.wrapAround!(Spacing, Lte, Spacing), pegged.peg.wrapAround!(Spacing, Neq, Spacing), pegged.peg.wrapAround!(Spacing, Gte, Spacing), pegged.peg.wrapAround!(Spacing, Gt, Spacing)), Spacing))), "PROMAL.Relation"), "Relation")(p);
                memo[tuple(`Relation`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Relation(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Lt, Spacing), pegged.peg.wrapAround!(Spacing, Lte, Spacing), pegged.peg.wrapAround!(Spacing, Neq, Spacing), pegged.peg.wrapAround!(Spacing, Gte, Spacing), pegged.peg.wrapAround!(Spacing, Gt, Spacing)), Spacing))), "PROMAL.Relation")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Simplexp, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Lt, Spacing), pegged.peg.wrapAround!(Spacing, Lte, Spacing), pegged.peg.wrapAround!(Spacing, Neq, Spacing), pegged.peg.wrapAround!(Spacing, Gte, Spacing), pegged.peg.wrapAround!(Spacing, Gt, Spacing)), Spacing))), "PROMAL.Relation"), "Relation")(TParseTree("", false,[], s));
        }
    }
    static string Relation(GetName g)
    {
        return "PROMAL.Relation";
    }

    static TParseTree Lt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Lt")(p);
        }
        else
        {
            if (auto m = tuple(`Lt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Lt"), "Lt")(p);
                memo[tuple(`Lt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Lt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Lt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Lt"), "Lt")(TParseTree("", false,[], s));
        }
    }
    static string Lt(GetName g)
    {
        return "PROMAL.Lt";
    }

    static TParseTree Lte(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Lte")(p);
        }
        else
        {
            if (auto m = tuple(`Lte`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Lte"), "Lte")(p);
                memo[tuple(`Lte`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Lte(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Lte")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<="), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Lte"), "Lte")(TParseTree("", false,[], s));
        }
    }
    static string Lte(GetName g)
    {
        return "PROMAL.Lte";
    }

    static TParseTree Neq(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<>"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Neq")(p);
        }
        else
        {
            if (auto m = tuple(`Neq`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<>"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Neq"), "Neq")(p);
                memo[tuple(`Neq`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Neq(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<>"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Neq")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<>"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Neq"), "Neq")(TParseTree("", false,[], s));
        }
    }
    static string Neq(GetName g)
    {
        return "PROMAL.Neq";
    }

    static TParseTree Gte(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Gte")(p);
        }
        else
        {
            if (auto m = tuple(`Gte`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Gte"), "Gte")(p);
                memo[tuple(`Gte`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Gte(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Gte")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">="), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Gte"), "Gte")(TParseTree("", false,[], s));
        }
    }
    static string Gte(GetName g)
    {
        return "PROMAL.Gte";
    }

    static TParseTree Gt(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Gt")(p);
        }
        else
        {
            if (auto m = tuple(`Gt`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Gt"), "Gt")(p);
                memo[tuple(`Gt`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Gt(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Gt")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">"), Spacing), pegged.peg.wrapAround!(Spacing, Simplexp, Spacing)), "PROMAL.Gt"), "Gt")(TParseTree("", false,[], s));
        }
    }
    static string Gt(GetName g)
    {
        return "PROMAL.Gt";
    }

    static TParseTree Simplexp(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Minus, Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Plus, Spacing), pegged.peg.wrapAround!(Spacing, Minus, Spacing)), Spacing))), "PROMAL.Simplexp")(p);
        }
        else
        {
            if (auto m = tuple(`Simplexp`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Minus, Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Plus, Spacing), pegged.peg.wrapAround!(Spacing, Minus, Spacing)), Spacing))), "PROMAL.Simplexp"), "Simplexp")(p);
                memo[tuple(`Simplexp`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Simplexp(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Minus, Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Plus, Spacing), pegged.peg.wrapAround!(Spacing, Minus, Spacing)), Spacing))), "PROMAL.Simplexp")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Minus, Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Plus, Spacing), pegged.peg.wrapAround!(Spacing, Minus, Spacing)), Spacing))), "PROMAL.Simplexp"), "Simplexp")(TParseTree("", false,[], s));
        }
    }
    static string Simplexp(GetName g)
    {
        return "PROMAL.Simplexp";
    }

    static TParseTree Minus(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), "PROMAL.Minus")(p);
        }
        else
        {
            if (auto m = tuple(`Minus`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), "PROMAL.Minus"), "Minus")(p);
                memo[tuple(`Minus`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Minus(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), "PROMAL.Minus")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("-"), Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), "PROMAL.Minus"), "Minus")(TParseTree("", false,[], s));
        }
    }
    static string Minus(GetName g)
    {
        return "PROMAL.Minus";
    }

    static TParseTree Plus(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("+"), Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), "PROMAL.Plus")(p);
        }
        else
        {
            if (auto m = tuple(`Plus`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("+"), Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), "PROMAL.Plus"), "Plus")(p);
                memo[tuple(`Plus`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Plus(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("+"), Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), "PROMAL.Plus")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("+"), Spacing), pegged.peg.wrapAround!(Spacing, Term, Spacing)), "PROMAL.Plus"), "Plus")(TParseTree("", false,[], s));
        }
    }
    static string Plus(GetName g)
    {
        return "PROMAL.Plus";
    }

    static TParseTree Term(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Mult, Spacing), pegged.peg.wrapAround!(Spacing, Div, Spacing), pegged.peg.wrapAround!(Spacing, Mod, Spacing), pegged.peg.wrapAround!(Spacing, Lshift, Spacing), pegged.peg.wrapAround!(Spacing, Rshift, Spacing)), Spacing))), "PROMAL.Term")(p);
        }
        else
        {
            if (auto m = tuple(`Term`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Mult, Spacing), pegged.peg.wrapAround!(Spacing, Div, Spacing), pegged.peg.wrapAround!(Spacing, Mod, Spacing), pegged.peg.wrapAround!(Spacing, Lshift, Spacing), pegged.peg.wrapAround!(Spacing, Rshift, Spacing)), Spacing))), "PROMAL.Term"), "Term")(p);
                memo[tuple(`Term`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Term(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Mult, Spacing), pegged.peg.wrapAround!(Spacing, Div, Spacing), pegged.peg.wrapAround!(Spacing, Mod, Spacing), pegged.peg.wrapAround!(Spacing, Lshift, Spacing), pegged.peg.wrapAround!(Spacing, Rshift, Spacing)), Spacing))), "PROMAL.Term")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Factor, Spacing), pegged.peg.zeroOrMore!(pegged.peg.wrapAround!(Spacing, pegged.peg.or!(pegged.peg.wrapAround!(Spacing, Mult, Spacing), pegged.peg.wrapAround!(Spacing, Div, Spacing), pegged.peg.wrapAround!(Spacing, Mod, Spacing), pegged.peg.wrapAround!(Spacing, Lshift, Spacing), pegged.peg.wrapAround!(Spacing, Rshift, Spacing)), Spacing))), "PROMAL.Term"), "Term")(TParseTree("", false,[], s));
        }
    }
    static string Term(GetName g)
    {
        return "PROMAL.Term";
    }

    static TParseTree Mult(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("*"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Mult")(p);
        }
        else
        {
            if (auto m = tuple(`Mult`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("*"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Mult"), "Mult")(p);
                memo[tuple(`Mult`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Mult(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("*"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Mult")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("*"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Mult"), "Mult")(TParseTree("", false,[], s));
        }
    }
    static string Mult(GetName g)
    {
        return "PROMAL.Mult";
    }

    static TParseTree Div(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("/"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Div")(p);
        }
        else
        {
            if (auto m = tuple(`Div`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("/"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Div"), "Div")(p);
                memo[tuple(`Div`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Div(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("/"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Div")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("/"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Div"), "Div")(TParseTree("", false,[], s));
        }
    }
    static string Div(GetName g)
    {
        return "PROMAL.Div";
    }

    static TParseTree Mod(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("%"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Mod")(p);
        }
        else
        {
            if (auto m = tuple(`Mod`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("%"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Mod"), "Mod")(p);
                memo[tuple(`Mod`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Mod(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("%"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Mod")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("%"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Mod"), "Mod")(TParseTree("", false,[], s));
        }
    }
    static string Mod(GetName g)
    {
        return "PROMAL.Mod";
    }

    static TParseTree Lshift(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<<"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Lshift")(p);
        }
        else
        {
            if (auto m = tuple(`Lshift`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<<"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Lshift"), "Lshift")(p);
                memo[tuple(`Lshift`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Lshift(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<<"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Lshift")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("<<"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Lshift"), "Lshift")(TParseTree("", false,[], s));
        }
    }
    static string Lshift(GetName g)
    {
        return "PROMAL.Lshift";
    }

    static TParseTree Rshift(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">>"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Rshift")(p);
        }
        else
        {
            if (auto m = tuple(`Rshift`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">>"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Rshift"), "Rshift")(p);
                memo[tuple(`Rshift`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Rshift(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">>"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Rshift")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(">>"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Rshift"), "Rshift")(TParseTree("", false,[], s));
        }
    }
    static string Rshift(GetName g)
    {
        return "PROMAL.Rshift";
    }

    static TParseTree Factor(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Charlit, String, True, False, Not, Number, pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("#")), Var), Func_call, pegged.peg.and!(pegged.peg.literal!("("), pegged.peg.option!(WS), Exp, pegged.peg.option!(WS), pegged.peg.literal!(")"))), "PROMAL.Factor")(p);
        }
        else
        {
            if (auto m = tuple(`Factor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(Charlit, String, True, False, Not, Number, pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("#")), Var), Func_call, pegged.peg.and!(pegged.peg.literal!("("), pegged.peg.option!(WS), Exp, pegged.peg.option!(WS), pegged.peg.literal!(")"))), "PROMAL.Factor"), "Factor")(p);
                memo[tuple(`Factor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Factor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(Charlit, String, True, False, Not, Number, pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("#")), Var), Func_call, pegged.peg.and!(pegged.peg.literal!("("), pegged.peg.option!(WS), Exp, pegged.peg.option!(WS), pegged.peg.literal!(")"))), "PROMAL.Factor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(Charlit, String, True, False, Not, Number, pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("#")), Var), Func_call, pegged.peg.and!(pegged.peg.literal!("("), pegged.peg.option!(WS), Exp, pegged.peg.option!(WS), pegged.peg.literal!(")"))), "PROMAL.Factor"), "Factor")(TParseTree("", false,[], s));
        }
    }
    static string Factor(GetName g)
    {
        return "PROMAL.Factor";
    }

    static TParseTree True(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("true"), Spacing), "PROMAL.True")(p);
        }
        else
        {
            if (auto m = tuple(`True`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("true"), Spacing), "PROMAL.True"), "True")(p);
                memo[tuple(`True`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree True(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("true"), Spacing), "PROMAL.True")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("true"), Spacing), "PROMAL.True"), "True")(TParseTree("", false,[], s));
        }
    }
    static string True(GetName g)
    {
        return "PROMAL.True";
    }

    static TParseTree False(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("false"), Spacing), "PROMAL.False")(p);
        }
        else
        {
            if (auto m = tuple(`False`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("false"), Spacing), "PROMAL.False"), "False")(p);
                memo[tuple(`False`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree False(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("false"), Spacing), "PROMAL.False")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("false"), Spacing), "PROMAL.False"), "False")(TParseTree("", false,[], s));
        }
    }
    static string False(GetName g)
    {
        return "PROMAL.False";
    }

    static TParseTree Not(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("not"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Not")(p);
        }
        else
        {
            if (auto m = tuple(`Not`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("not"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Not"), "Not")(p);
                memo[tuple(`Not`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Not(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("not"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Not")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("not"), Spacing), pegged.peg.wrapAround!(Spacing, Factor, Spacing)), "PROMAL.Not"), "Not")(TParseTree("", false,[], s));
        }
    }
    static string Not(GetName g)
    {
        return "PROMAL.Not";
    }

    static TParseTree Var(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "PROMAL.Var")(p);
        }
        else
        {
            if (auto m = tuple(`Var`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "PROMAL.Var"), "Var")(p);
                memo[tuple(`Var`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Var(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "PROMAL.Var")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, id, Spacing), pegged.peg.option!(pegged.peg.wrapAround!(Spacing, pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("["), Spacing), pegged.peg.wrapAround!(Spacing, Exp, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("]"), Spacing)), Spacing))), "PROMAL.Var"), "Var")(TParseTree("", false,[], s));
        }
    }
    static string Var(GetName g)
    {
        return "PROMAL.Var";
    }

    static TParseTree Cast(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":>"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":."), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@."), Spacing)), "PROMAL.Cast")(p);
        }
        else
        {
            if (auto m = tuple(`Cast`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":>"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":."), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@."), Spacing)), "PROMAL.Cast"), "Cast")(p);
                memo[tuple(`Cast`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Cast(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":>"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":."), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@."), Spacing)), "PROMAL.Cast")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":>"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!(":."), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@<"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@-"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@+"), Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("@."), Spacing)), "PROMAL.Cast"), "Cast")(TParseTree("", false,[], s));
        }
    }
    static string Cast(GetName g)
    {
        return "PROMAL.Cast";
    }

    static TParseTree Charlit(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, Char, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing)), "PROMAL.Charlit")(p);
        }
        else
        {
            if (auto m = tuple(`Charlit`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, Char, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing)), "PROMAL.Charlit"), "Charlit")(p);
                memo[tuple(`Charlit`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Charlit(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, Char, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing)), "PROMAL.Charlit")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing), pegged.peg.wrapAround!(Spacing, Char, Spacing), pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("'"), Spacing)), "PROMAL.Charlit"), "Charlit")(TParseTree("", false,[], s));
        }
    }
    static string Charlit(GetName g)
    {
        return "PROMAL.Charlit";
    }

    static TParseTree Keyword(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("end", "program", "own", "export", "con", "byte", "word", "int", "real", "ext", "global", "data", "proc", "func", "begin", "end", "asm", "at", "arg", "list", "if", "choose", "while", "repeat", "for", "else", "return", "nothing", "refuge", "escape", "break", "next", "case", "else", "until", "and", "or", "xor", "true", "false", "not", "call"), "PROMAL.Keyword")(p);
        }
        else
        {
            if (auto m = tuple(`Keyword`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("end", "program", "own", "export", "con", "byte", "word", "int", "real", "ext", "global", "data", "proc", "func", "begin", "end", "asm", "at", "arg", "list", "if", "choose", "while", "repeat", "for", "else", "return", "nothing", "refuge", "escape", "break", "next", "case", "else", "until", "and", "or", "xor", "true", "false", "not", "call"), "PROMAL.Keyword"), "Keyword")(p);
                memo[tuple(`Keyword`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Keyword(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("end", "program", "own", "export", "con", "byte", "word", "int", "real", "ext", "global", "data", "proc", "func", "begin", "end", "asm", "at", "arg", "list", "if", "choose", "while", "repeat", "for", "else", "return", "nothing", "refuge", "escape", "break", "next", "case", "else", "until", "and", "or", "xor", "true", "false", "not", "call"), "PROMAL.Keyword")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("end", "program", "own", "export", "con", "byte", "word", "int", "real", "ext", "global", "data", "proc", "func", "begin", "end", "asm", "at", "arg", "list", "if", "choose", "while", "repeat", "for", "else", "return", "nothing", "refuge", "escape", "break", "next", "case", "else", "until", "and", "or", "xor", "true", "false", "not", "call"), "PROMAL.Keyword"), "Keyword")(TParseTree("", false,[], s));
        }
    }
    static string Keyword(GetName g)
    {
        return "PROMAL.Keyword";
    }

    static TParseTree Number(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(Scientific, Floating, Integer, Hexa)), "PROMAL.Number")(p);
        }
        else
        {
            if (auto m = tuple(`Number`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(Scientific, Floating, Integer, Hexa)), "PROMAL.Number"), "Number")(p);
                memo[tuple(`Number`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Number(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(Scientific, Floating, Integer, Hexa)), "PROMAL.Number")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(Scientific, Floating, Integer, Hexa)), "PROMAL.Number"), "Number")(TParseTree("", false,[], s));
        }
    }
    static string Number(GetName g)
    {
        return "PROMAL.Number";
    }

    static TParseTree String(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), doublequote)), "PROMAL.String")(p);
        }
        else
        {
            if (auto m = tuple(`String`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), doublequote)), "PROMAL.String"), "String")(p);
                memo[tuple(`String`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree String(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), doublequote)), "PROMAL.String")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), Char)), doublequote)), "PROMAL.String"), "String")(TParseTree("", false,[], s));
        }
    }
    static string String(GetName g)
    {
        return "PROMAL.String";
    }

    static TParseTree Char(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.literal!("x"), Hexa))), pegged.peg.any)), "PROMAL.Char")(p);
        }
        else
        {
            if (auto m = tuple(`Char`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.literal!("x"), Hexa))), pegged.peg.any)), "PROMAL.Char"), "Char")(p);
                memo[tuple(`Char`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Char(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.literal!("x"), Hexa))), pegged.peg.any)), "PROMAL.Char")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(backslash, pegged.peg.or!(doublequote, quote, backslash, pegged.peg.or!(pegged.peg.literal!("b"), pegged.peg.literal!("f"), pegged.peg.literal!("n"), pegged.peg.literal!("r"), pegged.peg.literal!("t")), pegged.peg.and!(pegged.peg.literal!("x"), Hexa))), pegged.peg.any)), "PROMAL.Char"), "Char")(TParseTree("", false,[], s));
        }
    }
    static string Char(GetName g)
    {
        return "PROMAL.Char";
    }

    static TParseTree Scientific(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Floating, pegged.peg.option!(pegged.peg.and!(pegged.peg.keywords!("e", "E"), Integer)))), "PROMAL.Scientific")(p);
        }
        else
        {
            if (auto m = tuple(`Scientific`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Floating, pegged.peg.option!(pegged.peg.and!(pegged.peg.keywords!("e", "E"), Integer)))), "PROMAL.Scientific"), "Scientific")(p);
                memo[tuple(`Scientific`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Scientific(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Floating, pegged.peg.option!(pegged.peg.and!(pegged.peg.keywords!("e", "E"), Integer)))), "PROMAL.Scientific")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Floating, pegged.peg.option!(pegged.peg.and!(pegged.peg.keywords!("e", "E"), Integer)))), "PROMAL.Scientific"), "Scientific")(TParseTree("", false,[], s));
        }
    }
    static string Scientific(GetName g)
    {
        return "PROMAL.Scientific";
    }

    static TParseTree Floating(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Integer, pegged.peg.option!(pegged.peg.and!(pegged.peg.literal!("."), Unsigned)))), "PROMAL.Floating")(p);
        }
        else
        {
            if (auto m = tuple(`Floating`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Integer, pegged.peg.option!(pegged.peg.and!(pegged.peg.literal!("."), Unsigned)))), "PROMAL.Floating"), "Floating")(p);
                memo[tuple(`Floating`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Floating(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Integer, pegged.peg.option!(pegged.peg.and!(pegged.peg.literal!("."), Unsigned)))), "PROMAL.Floating")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(Integer, pegged.peg.option!(pegged.peg.and!(pegged.peg.literal!("."), Unsigned)))), "PROMAL.Floating"), "Floating")(TParseTree("", false,[], s));
        }
    }
    static string Floating(GetName g)
    {
        return "PROMAL.Floating";
    }

    static TParseTree Unsigned(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), "PROMAL.Unsigned")(p);
        }
        else
        {
            if (auto m = tuple(`Unsigned`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), "PROMAL.Unsigned"), "Unsigned")(p);
                memo[tuple(`Unsigned`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Unsigned(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), "PROMAL.Unsigned")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), "PROMAL.Unsigned"), "Unsigned")(TParseTree("", false,[], s));
        }
    }
    static string Unsigned(GetName g)
    {
        return "PROMAL.Unsigned";
    }

    static TParseTree Integer(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Unsigned)), "PROMAL.Integer")(p);
        }
        else
        {
            if (auto m = tuple(`Integer`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Unsigned)), "PROMAL.Integer"), "Integer")(p);
                memo[tuple(`Integer`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Integer(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Unsigned)), "PROMAL.Integer")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(Sign), Unsigned)), "PROMAL.Integer"), "Integer")(TParseTree("", false,[], s));
        }
    }
    static string Integer(GetName g)
    {
        return "PROMAL.Integer";
    }

    static TParseTree Hexa(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("$"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F'))))), "PROMAL.Hexa")(p);
        }
        else
        {
            if (auto m = tuple(`Hexa`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("$"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F'))))), "PROMAL.Hexa"), "Hexa")(p);
                memo[tuple(`Hexa`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Hexa(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("$"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F'))))), "PROMAL.Hexa")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("$"), pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'), pegged.peg.charRange!('A', 'F'))))), "PROMAL.Hexa"), "Hexa")(TParseTree("", false,[], s));
        }
    }
    static string Hexa(GetName g)
    {
        return "PROMAL.Hexa";
    }

    static TParseTree Sign(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "PROMAL.Sign")(p);
        }
        else
        {
            if (auto m = tuple(`Sign`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "PROMAL.Sign"), "Sign")(p);
                memo[tuple(`Sign`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Sign(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "PROMAL.Sign")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "PROMAL.Sign"), "Sign")(TParseTree("", false,[], s));
        }
    }
    static string Sign(GetName g)
    {
        return "PROMAL.Sign";
    }

    static TParseTree Vartype(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("byte", "word", "int", "real"), "PROMAL.Vartype")(p);
        }
        else
        {
            if (auto m = tuple(`Vartype`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("byte", "word", "int", "real"), "PROMAL.Vartype"), "Vartype")(p);
                memo[tuple(`Vartype`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Vartype(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("byte", "word", "int", "real"), "PROMAL.Vartype")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("byte", "word", "int", "real"), "PROMAL.Vartype"), "Vartype")(TParseTree("", false,[], s));
        }
    }
    static string Vartype(GetName g)
    {
        return "PROMAL.Vartype";
    }

    static TParseTree WS(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.or!(space, eol, Comment))), "PROMAL.WS")(p);
        }
        else
        {
            if (auto m = tuple(`WS`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.or!(space, eol, Comment))), "PROMAL.WS"), "WS")(p);
                memo[tuple(`WS`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree WS(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.or!(space, eol, Comment))), "PROMAL.WS")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.zeroOrMore!(pegged.peg.or!(space, eol, Comment))), "PROMAL.WS"), "WS")(TParseTree("", false,[], s));
        }
    }
    static string WS(GetName g)
    {
        return "PROMAL.WS";
    }

    static TParseTree Comment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("//"), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)), eol)), "PROMAL.Comment")(p);
        }
        else
        {
            if (auto m = tuple(`Comment`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("//"), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)), eol)), "PROMAL.Comment"), "Comment")(p);
                memo[tuple(`Comment`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Comment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("//"), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)), eol)), "PROMAL.Comment")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!("//"), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(eol), pegged.peg.any)), eol)), "PROMAL.Comment"), "Comment")(TParseTree("", false,[], s));
        }
    }
    static string Comment(GetName g)
    {
        return "PROMAL.Comment";
    }

    static TParseTree id(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.negLookahead!(Keyword), pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))))), "PROMAL.id")(p);
        }
        else
        {
            if (auto m = tuple(`id`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.negLookahead!(Keyword), pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))))), "PROMAL.id"), "id")(p);
                memo[tuple(`id`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree id(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.negLookahead!(Keyword), pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))))), "PROMAL.id")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.negLookahead!(Keyword), pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_")), pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('A', 'Z'), pegged.peg.literal!("_"), pegged.peg.charRange!('0', '9'))))), "PROMAL.id"), "id")(TParseTree("", false,[], s));
        }
    }
    static string id(GetName g)
    {
        return "PROMAL.id";
    }

    static TParseTree EOI(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.negLookahead!(pegged.peg.any), "PROMAL.EOI")(p);
        }
        else
        {
            if (auto m = tuple(`EOI`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.negLookahead!(pegged.peg.any), "PROMAL.EOI"), "EOI")(p);
                memo[tuple(`EOI`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree EOI(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.negLookahead!(pegged.peg.any), "PROMAL.EOI")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.negLookahead!(pegged.peg.any), "PROMAL.EOI"), "EOI")(TParseTree("", false,[], s));
        }
    }
    static string EOI(GetName g)
    {
        return "PROMAL.EOI";
    }

    static TParseTree NL(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.keywords!("\r", "\n", "\r\n")), "PROMAL.NL")(p);
        }
        else
        {
            if (auto m = tuple(`NL`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.keywords!("\r", "\n", "\r\n")), "PROMAL.NL"), "NL")(p);
                memo[tuple(`NL`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree NL(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.keywords!("\r", "\n", "\r\n")), "PROMAL.NL")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.keywords!("\r", "\n", "\r\n")), "PROMAL.NL"), "NL")(TParseTree("", false,[], s));
        }
    }
    static string NL(GetName g)
    {
        return "PROMAL.NL";
    }

    static TParseTree Spacing(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.keywords!(" ", "\t"))), "PROMAL.Spacing")(p);
        }
        else
        {
            if (auto m = tuple(`Spacing`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.keywords!(" ", "\t"))), "PROMAL.Spacing"), "Spacing")(p);
                memo[tuple(`Spacing`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Spacing(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.keywords!(" ", "\t"))), "PROMAL.Spacing")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.keywords!(" ", "\t"))), "PROMAL.Spacing"), "Spacing")(TParseTree("", false,[], s));
        }
    }
    static string Spacing(GetName g)
    {
        return "PROMAL.Spacing";
    }

    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(Program(p));
        result.children = [result];
        result.name = "PROMAL";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return PROMAL(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            forgetMemo();
            return PROMAL(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "PROMAL";
    }


    static void forgetMemo()
    {
        memo = null;
    }
    }
}

alias GenericPROMAL!(ParseTree).PROMAL PROMAL;


