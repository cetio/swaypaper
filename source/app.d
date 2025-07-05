import std.process;
import std.file;
import std.random;
import std.array;
import std.path;
import std.string;
import core.thread;
import std.datetime;
import std.conv;

void main(string[] args)
{
    immutable string CONFIG_PATH = expandTilde("~/.config/swaypaper/config");
    immutable string CMD_PATH = expandTilde("~/.cache/swaypaper.cmd");
    int INTERVAL_MAX = 10;

    int index;
    string[] dirs;
    int interval = INTERVAL_MAX;

    if (args.length > 1)
    {
        if (args[1] == "next")
            write(CMD_PATH, cast(ubyte[])"next");
        else if (args[1] == "prev")
            write(CMD_PATH, cast(ubyte[])"prev");
        else if (args[1] == "now")
            write(CMD_PATH, cast(ubyte[])"now");
        else if (args[1] == "stop")
            write(CMD_PATH, cast(ubyte[])"stop");
        return;
    }

    while (true)
    {
        if (exists(CONFIG_PATH))
        {
            dirs = readText(CONFIG_PATH).splitLines;
            if (dirs.length <= 1)
                throw new Throwable("Config must contain interval (in msecs) followed by one directory per line.");

            INTERVAL_MAX = dirs[0].to!int / 100;
            dirs = dirs[1..$];
        }
        else
            throw new Throwable("Missing ~/.config/swaypaper/config. Config must contain interval (in msecs) followed by one directory per line.");

        if (!exists(CMD_PATH))
            write(CMD_PATH, new ubyte[0]);

        switch (readText(CMD_PATH).strip)
        {
        case "next":
            write(CMD_PATH, new ubyte[0]);
            index = index + 1 >= dirs.length ? 0 : index + 1;
            interval = 0;
            break;
        case "prev":
            write(CMD_PATH, new ubyte[0]);
            index = index - 1 < 0 ? cast(int)dirs.length - 1 : index - 1;
            interval = 0;
            break;
        case "now":
            write(CMD_PATH, new ubyte[0]);
            interval = 0;
            break;
        case "stop":
            write(CMD_PATH, new ubyte[0]);
            return;
        default:
            write(CMD_PATH, new ubyte[0]);
            break;
        }

        if (interval == 0)
        {
            string wallpaper = choice(dirEntries(expandTilde(dirs[index]), SpanMode.shallow).array).name;
            executeShell("swww img "~wallpaper);
            interval = INTERVAL_MAX;
            continue;
        }

        Thread.sleep(dur!"msecs"(100));
        interval--;
    }
}
