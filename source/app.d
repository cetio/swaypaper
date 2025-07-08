import std.process;
import std.file;
import std.random;
import std.array;
import std.path;
import std.string;
import core.thread;
import std.datetime;
import std.conv;
import std.algorithm;
import std.json;

enum Slideshow
{
    Random,
    Sequential
}

void main(string[] args)
{
    immutable string CONFIG_PATH = expandTilde("~/.config/swaypaper/config");
    immutable string CMD_PATH = expandTilde("~/.cache/swaypaper.cmd");
    ulong INTERVAL_MAX = 1;

    JSONValue json;

    size_t didx = -1;
    size_t widx;
    Slideshow kind;
    string[] dirs;
    string[] wallpapers;
    ulong interval = INTERVAL_MAX;

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
        if (!exists(CMD_PATH))
            write(CMD_PATH, new ubyte[0]);

        switch (readText(CMD_PATH).strip)
        {
        case "next":
            write(CMD_PATH, new ubyte[0]);
            didx = didx + 1 >= dirs.length ? 0 : didx + 1;
            interval = 0;
            widx = 0;
            break;
        case "prev":
            write(CMD_PATH, new ubyte[0]);
            didx = didx - 1 < 0 ? dirs.length - 1 : didx - 1;
            interval = 0;
            widx = 0;
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
            // TODO: This is all unoptimized garbage.
            if (exists(CONFIG_PATH))
            {
                // TODO: Error checking?
                json = parseJSON(readText(CONFIG_PATH));
                dirs = json["dirs"].array.map!(x => x.str).array;
                INTERVAL_MAX = json["interval"].integer / 100;

                if (didx == -1)
                    didx = json["current"].integer;
                else if (didx != json["current"].integer)
                {
                    json["current"] = didx;
                    // TODO: This butchers original layout.
                    write(CONFIG_PATH, json.toPrettyString);
                }

                // TODO: This could be an associative array, but this codebase sucks anyway.
                switch (json["slideshow"].str)
                {
                case "random":
                    kind = Slideshow.Random;
                    break;
                case "sequential":
                    kind = Slideshow.Sequential;
                    break;
                default:
                    assert(0);
                }
            }
            else
                throw new Throwable("Missing ~/.config/swaypaper/config.");

            if (dirEntries(expandTilde(dirs[didx]), SpanMode.shallow).array != wallpapers)
                wallpapers = dirEntries(expandTilde(dirs[didx]), SpanMode.shallow).map!(x => x.name).array;

            string wallpaper;
            if (kind == Slideshow.Random)
                wallpaper = choice(wallpapers);
            else if (Slideshow.Sequential)
            // TODO: It no work.
                wallpaper = wallpapers[widx + 1 >= dirs.length ? widx = 0 : widx++];

            if (wallpaper.indexOf(".stretch") != -1)
                executeShell("swww img "~wallpaper~" --resize stretch");
            else if (wallpaper.indexOf(".fit") != -1)
                executeShell("swww img "~wallpaper~" --resize fit");
            else
                executeShell("swww img "~wallpaper);

            interval = INTERVAL_MAX;
            continue;
        }

        Thread.sleep(dur!"msecs"(100));
        interval--;
    }
}
