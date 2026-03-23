module main;

import automata;

import
    std.stdio,
    std.getopt,
    std.path,
    std.file;

import core.runtime : Runtime;

string argzero;

static this()
{
    argzero = baseName(Runtime.args[0]);
}

struct settings
{
    bool help;
    bool vers;
    bool verbose;
    string confpath;
}

int usage(int rc)
{
    writefln("usage: %s [options...]", argzero);
    writeln("options:");
    writeln("  -v [ --verbose ] Don't redirect program output");
    writeln("  -c [ --config  ] Specify configuation file path");
    writeln("  -V [ --version ] Display version info");
    writeln("  -h [ --help    ] Display this usage info");
    return rc;
}

int usageversion(int rc)
{
    writefln("%s version %s", argzero, VERSION);
    return rc;
}

int main(string[] args)
{
    settings s;
    try
    {
        getopt(args,
            std.getopt.config.caseSensitive,
            std.getopt.config.bundling,
            "c|config", &s.confpath,
            "V|version", &s.vers,
            "v|verbose", &s.verbose,
            "h|help", &s.help
        );
        if (s.vers)
            return usageversion(0);

        if (s.help)
            return usage(0);

        if (s.confpath.length == 0)
            s.confpath = xdgConfigHome() ~ "/automata/config.toml";

        if (!s.confpath.exists)
        {
            stderr.writefln("\033[31m%s\033[m: requested path '%s' does not exist!", argzero, s.confpath);
            return 1;
        }
    }
    catch (GetOptException err)
    {
        stderr.writefln("\033[31m%s\033[m: %s", argzero, err.msg);
        return 1;
    }


    auto daemons = parseConfig(s.confpath);
    int result = 0;
    foreach (d; daemons)
        result += d.run(s.verbose);
    return result;
}
