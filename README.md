# Friday Night Funkin Disappointing Plus
[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2FTheDrawingCoder-Gamer%2FFunkin%2Fbadge%3Fref%3Dmaster&style=for-the-badge)](https://actions-badge.atrox.dev/TheDrawingCoder-Gamer/Funkin/goto?ref=master)
![Azure DevOps builds](https://img.shields.io/azure-devops/build/benharless820/7af207e5-72fd-483f-9a48-6fc65e63abb9/4?label=pipelines&style=for-the-badge)
[![forthebadge](https://forthebadge.com/images/badges/fuck-it-ship-it.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/works-on-my-machine.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/contains-tasty-spaghetti-code.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/it-works-why.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/just-plain-nasty.svg)](https://forthebadge.com)

This is the repository for Friday Night Funkin Disappointing Plus, a fork of Modding Plus, set on continuing to use and update an
outdated engine for the fun of it!

Feel free to use this in any of your mods! You're passing up using something better, like Psych engine, or even base FNF itself, just so you know.

But remember, any mods made with this mod must have express permission from the creator of songs included. 
(for example, if you include the Whitty Mod, you should have express permission from Nate Anim8, KadeDev, and SockClip.
I, at least, would like to see the main author and a majority of secondary offers get express permission)
If an author gives express disapproval, and the mod is up, you should take your mod down. 
Though, I would hope that the FNF community is past just porting a mod to another engine and reuploading it as their own.

- The original Modding Plus can be found here: https://github.com/FunkinModdingPlus/ModdingPlus
- Base FNF's code can be found here: https://github.com/ninjamuffin99/Funkin
Note: I do use some code from newer version of base FNF, but I try my best to not copy and paste, when I can
## Credits for the Original Game

- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [KawaiSprite](https://twitter.com/kawaisprite) - Musician
- [Additional Credits](https://github.com/FunkinCrew/funkin.assets/blob/main/exclude/data/credits.json)
## Modding+ Credits

- [BulbyVR](https://github.com/TheDrawingCoder-Gamer) - Owner/Programmer
- [DJ Popsicle](https://gamebanana.com/members/1780306) - Co-Owner/Additional Programmer
- [Matheus L/Mlops](https://gamebanana.com/members/1767306), [AndreDoodles](https://gamebanana.com/members/1764840), riko, Raf, ElBartSinsoJaJa, and [plum](https://www.youtube.com/channel/UCXbiI4MJD9Y3FpjW61lG8ZQ) - Artist & Animation
- [ThePinkPhantom/JuliettePink](https://gamebanana.com/members/1892442) - Portrait Artist
- [Alex Director](https://gamebanana.com/members/1701629) - Icon Fixer
- [Drippy](https://github.com/TrafficKid) - GitHub Wikipedia
- [GwebDev](https://github.com/GrowtopiaFli) - Edited WebM code
- [Axy](https://github.com/timeless13GH) - Poggers help
## Disappointing+ Credits
 - [Roblox Disappointment](https://github.com/AFunkinDisappointment) - Mediocre Coder
I didn't really need to credit myself, but I wanted to mention that most of the code is from the Modding Plus team listed above!
This is just my sole additions to this defuncted engine.
I'm definitely not that experienced, but I try my best!

## Build instructions

THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!

IF YOU WANT TO JUST DOWNLOAD, INSTALL, AND PLAY THE GAME NORMALLY, GO TO THE GITHUB'S RELEASES TO DOWNLOAD THE GAME FOR PC!!

https://github.com/AFunkinDisappointment/DisappointingPlus/releases

IF YOU WANT TO COMPILE THE GAME YOURSELF, OR PLAY ON MAC OR LINUX, CONTINUE READING!!!

IF YOU MAKE A MOD AND DISTRIBUTE A MODIFIED / RECOMIPLED VERSION, YOU MUST OPEN SOURCE YOUR MOD AS WELL

### Installing shit

First you need to install Haxe and HaxeFlixel. I'm too lazy to write and keep updated with that setup (which is pretty simple).
The link to that is on the [HaxeFlixel website](https://haxeflixel.com/documentation/getting-started/)

Other installations you'd need is the additional libraries, a fully updated list will be in `Project.xml` in the project root, but here are the one's I'm using as of writing.

```
hscript
flixel-ui
tjson
json2object
uniontypes
hxcpp-debug-server
```

So for each of those type `haxelib install [library]` so shit like `haxelib install hscript`

You'll also need to install hscript-ex. Do this with

```
haxelib git hscript-ex https://github.com/ianharrigan/hscript-ex
```


### Compiling game


To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run 'lime test linux -debug' and then run the executible file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
* C++ Profiling tools
* C++ CMake tools for windows
* C++ ATL for v142 build tools (x86 & x64)
* C++ MFC for v142 build tools (x86 & x64)
* C++/CLI support for v142 build tools (14.21)
* C++ Modules for v142 build tools (x64/x86)
* Clang Compiler for Windows
* Windows 10 SDK (10.0.17134.0)
* Windows 10 SDK (10.0.16299.0)
* MSVC v141 - VS 2017 C++ x64/x86 build tools
* MSVC v140 - VS 2015 C++ build tools (v14.00)

This will install about 22GB of crap, but once that is done you can open up a command line in the project's directory and run `lime test windows -debug`. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin
As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.
### Additional guides

- [Command line basics](https://ninjamuffin99.newgrounds.com/news/post/1090480)
