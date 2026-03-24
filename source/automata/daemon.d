module automata.daemon;

import automata.util;

import std.string, std.array, std.stdio, std.process, std.file, std.path;
import core.stdc.stdlib : exit;
import toml;

class daemon
{
    string name;
    string path;
    string wdir;
    string[] args;
    bool clean_env;
    string[string] envs;
    string[] unsetenvs;

    this() {};

    string tostring() const
    {
        auto app = appender!string();
        app.put(format("name: %s\n", name));
        if (path.length > 0)
            app.put(format("path: %s\n", path));
        else
            app.put(format("path: %s\n", findExe(name)));

        if (args.length > 0)
        {
            app.put("args: ");
            foreach (arg; args)
            {
                app.put(arg ~ " ");
            }
            app.put("\n");
        }

        return app.data;
    }

    bool alreadyRunning()
    {
        string ppath;
        if (path.length > 0)
            ppath = path;
        else
            ppath = findExe(name);

        auto result = execute(["pgrep", "-f", ppath]);
        auto resultstr = cast(string)result.output;
        resultstr = resultstr.strip;
        if (resultstr.length != 0)
            return true;
        else return false;
    }

    string[] cmdline()
    {
        string[] result;
        if (path.length > 0)
            result ~= path;
        else
            result ~= name;

        if (args.length > 0)
            foreach (arg; args)
                result ~= arg;
        return result;
    }

    int run(bool verbose = false)
    {
        if (alreadyRunning())
        {
            writefln("\033[33mautomata\033[m: %s is already running, skipping.", name);
            return 0;
        }
        try
        {
            Config cfg;
            string wd;
            Pid pid;
            if (verbose)
            {
                wd = (wdir.length > 0 ? wdir : null);
                cfg = Config.newEnv;
                string[string] nenvs = environment.toAA;
                foreach (k, v; envs)
                    nenvs[k] = v;

                foreach (k; unsetenvs)
                    nenvs.remove(k);

                if (clean_env)
                    nenvs = null;
                pid = spawnProcess(this.cmdline(), stdin, stdout, stderr, nenvs, cfg, wd);
            }
            else
            {
                auto dnull = File("/dev/null", "w");
                scope(exit) dnull.close();
                wd = (wdir.length > 0 ? wdir : null);
                cfg = Config.newEnv;
                string[string] nenvs = environment.toAA;
                foreach (k, v; envs)
                    nenvs[k] = v;

                foreach (k; unsetenvs)
                    nenvs.remove(k);

                if (clean_env)
                    nenvs = null;

                pid = spawnProcess(this.cmdline(), stdin, dnull, dnull, nenvs, cfg, wd);
            }

        }
        catch (ProcessException err)
        {
            stderr.writeln("failed spawning process: " ~ err.msg);
            return 1;
        }
        writefln("\033[32mautomata\033[m: spawned %s", name);
        return 0;
    }
}

daemon[] parseConfig(string path)
{
    daemon[] daemons;
    try
    {
        auto doc = parseTOML(cast(string)read(path));
        auto progs = doc["prog"].array;
        foreach (p; progs)
        {
            auto d = new daemon();

            if ("name" !in p)
            {
                stderr.writeln("error, daemon is missing a name!");
                exit(1);
            }
            else
            {
                d.name = p["name"].str;
            }

            if ("path" in p)
            {
                d.path = p["path"].str;
            }

            if ("directory" in p)
            {
                d.wdir = parseDirectory(p["directory"].str);
            }

            if ("args" in p)
            {
                auto dargs = p["args"].array;
                foreach (arg; dargs)
                {
                    d.args ~= arg.str;
                }
            }

            if ("freshenv" in p)
            {
                d.clean_env = p["freshenv"].boolean;
            }

            if ("envs" in p)
            {
                foreach (k, v; p["envs"])
                {
                    d.envs[k] = v.str;
                }
            }

            if ("unset-envs" in p)
            {
                foreach (key; p["unset-envs"].array)
                {
                    d.unsetenvs ~=  key.str;
                }
            }

            daemons ~= d;
        }
    }
    catch (TOMLException err)
    {
        stderr.writeln(err.msg);
        exit(1);
    }
    return daemons;
}
