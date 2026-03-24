module automata.config;

import
    std.process,
    std.array,
    std.format,
    core.sys.posix.unistd;

string xdgConfigHome()
{
    auto p = environment["XDG_CONFIG_HOME"];
    if (p.length == 0)
        p = environment["HOME"] ~ "/.config";
    return p;
}

string xdgDataHome()
{
    auto p = environment["XDG_DATA_HOME"];
    if (p.length == 0)
        p = environment["HOME"] ~ "/.local/share";
    return p;
}

string xdgStateHome()
{
    auto p = environment["XDG_STATE_HOME"];
    if (p.length == 0)
        p = environment["HOME"] ~ "/.local/state";
    return p;
}

string xdgCacheHome()
{
    auto p = environment["XDG_CACHE_HOME"];
    if (p.length == 0)
        p = environment["HOME"] ~ "/.cache";
    return p;
}

string[] xdgDataDirs()
{
    auto p = environment["XDG_DATA_DIRS"];
    if (p.length > 0)
        return p.split(":");
    else
        return ["/usr/local/share", "/usr/share"];
}

string[] xdgConfigDirs()
{
    auto p = environment["XDG_CONFIG_DIRS"];
    if (p.length > 0)
        return p.split(":");
    else
        return ["/etc/local/xdg", "/etc/xdg"];
}

string xdgRuntimeDir()
{
    auto p = environment["XDG_RUNTIME_DIR"];
    if (p.length <= 0)
        return format("/run/user/%d", geteuid());
    else return p;
}