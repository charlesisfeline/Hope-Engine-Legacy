# Building

> THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!
>
> IF YOU WANT TO JUST DOWNLOAD AND INSTALL AND PLAY THE GAME NORMALLY, GO TO ITCH.IO TO DOWNLOAD THE GAME FOR PC, MAC, AND LINUX!!
>
> <https://ninja-muffin24.itch.io/funkin>
>
> IF YOU WANT TO COMPILE THE GAME YOURSELF, CONTINUE READING!!!

### Notes
- **You need to be familiar with the command line!** Check this guide out by ninjamuffin99 if you're not familiar: <https://ninjamuffin99.newgrounds.com/news/post/1090480>
- **To build in one platform, one must be in that platform.** Like your computer must be Windows in order to build for Windows. _For HTML5, you can use any platform._

### Getting the needed stuff
- [Install the **latest** version of Haxe.](https://haxe.org/download/) Not 4.1.5.
- [Follow these directions to install HaxeFlixel.](https://haxeflixel.com/documentation/install-haxeflixel/)
- Install [git-scm](https://git-scm.com/downloads).
    - For **Linux** --  install the git package: sudo apt install git (ubuntu), sudo pacman -S git (arch), etc… (you probably already have it) (from Kade Engine building).
- Install these needed libraries:
    - `haxelib install flixel`
    - `haxelib install flixel-addons`
    - `haxelib install flixel-ui`
    - `haxelib install hscript`
    - `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc`
<br>_This list may grow soon!_

### Windows only dependencies (building _to_ Windows. HTML5 doesn't require these.)
If you are planning to build for Windows, you may have to install [**Visual Studio 2019**](https://docs.microsoft.com/en-us/visualstudio/releases/2019/release-notes). Be sure to get the Community version. 

While installing, here's what's actually needed:
![](https://github.com/skuqre/Hope-Engine/blob/site/images/windowsdependencies.png?raw=true)

<details>
    <summary>Don't understand? Click me!</summary>
    <ul>
        <li>Tick "Desktop Development with C++" first, look to the sidebar.</li>
        <li>Keep MSVC v142 - VS 2019 C++ x64/x86 build tools ticked. (ANY version, can be latest!)</li>
        <li>Keep Windows 10 SDK ticked. (ANY version!)</li>
    <ul>    
</details>

About 6 GB is needed for this crap, but hell it is necessary.

### (from Kade Engine) MacOS only dependencies (building _on_ macOS at all)

You'll need to install [Xcode](https://developer.apple.com/xcode/).

If you get an error saying that you need a newer macOS version, you'll need to download an older version of Xcode from the [More Software Downloads](https://developer.apple.com/download/more/) section.

(for Old versions) Not sure what version? Check this Wikipedia page out: <br>
<https://en.wikipedia.org/wiki/Xcode#Version_comparison_table>

### Building
After you've set all the needed things, installed all the needed stuff -- time to get building.

Open up a command prompt in your directory -- the guide by ninjamuffin99 is [here](https://ninjamuffin99.newgrounds.com/news/post/1090480).

- Run `lime build <target>`, except replace `<target>` with the platform you would like to build to (`windows`, `mac`, `linux`, `html5`). Like `lime build windows`.
- The build will be located at `export > release > <target> > bin`, with target being the one you typed in the previous step, like `windows`.
- If you have done the command with `-debug`, it will be located at `debug` instead of `release`.
- Only the `bin` folder is necessary, the other ones in the `export > release > <target>` folder are not.
- Builds built with the `-debug` flag will have debugging capabilities. Press \` or \ to see the debug menu. Builds like these have the ability to show you the stack trace and fix `Null Object Reference` errors easily.
