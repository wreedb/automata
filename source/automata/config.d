module automata.config;

import std.process;

string xdgConfigHome()
{
    auto p = environment["XDG_CONFIG_HOME"];
    if (p.length == 0)
        p = environment["HOME"] ~ "/.config";
    return p;
}
