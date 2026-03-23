module automata.util;

import std.file : getAttributes, exists, dirEntries, SpanMode, isDir;
import std.path : baseName;
import std.array : split;
import std.stdio : stderr, writeln;
import std.process : environment;
import core.sys.posix.sys.stat : S_IXGRP, S_IXOTH, S_IXUSR;
import core.stdc.stdlib : exit;

bool executable(string path)
{
    auto attrs = path.getAttributes;
    if ((attrs & (S_IXUSR | S_IXGRP | S_IXOTH)) != 0)
        return true;
    return false;
}

string[] getpath()
{
    return environment.get("PATH", "/usr/local/bin:/usr/bin").split(":");
}

string findExe(string name)
{
    string[] path = getpath();

    foreach (dir; path)
    {
        // skip if the dir doesnt exist
        if (!dir.exists || !dir.isDir) continue;

        foreach (string f; dirEntries(dir, SpanMode.shallow))
        {
            if (baseName(f) == name)
            {
                if (executable(f))
                {
                    return f;
                }
            }
        }
    }
    return "";
}


string parseDirectory(string s)
{
    if (s == "$HOME")
        return environment["HOME"];

    if (!s.isDir)
    {
        stderr.writeln("error parsing directory '%s', path doesn't exist!", s);
        exit(1);
    }

    return s;
}
