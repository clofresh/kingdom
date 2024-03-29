# A Kingdom Divided

![Screenshot](https://raw.github.com/clofresh/kingdom/master/screenshot.png?login=clofresh&token=337ee77b2fae48ed08192f89e45d1955)

## Dependencies

In order to run the game, you'll need [Lua Löve 0.8.0](https://love2d.org/). If working from a git checkout, you'll need to get the git submodules:

    git submodule init
    git submodule update

If you want to edit the maps, you'll need [Tiled](http://www.mapeditor.org/)

## Running the game

To run the game, make sure Löve is installed and `love` is in your PATH, then just run:

    love .

## Design

[Design doc](https://docs.google.com/document/d/1T7Q46gwFaszmF_SlOxIIxRMw4OTJ0CDKVcL9Ql5Re5g/edit)

## Code

### Directory structure

* audio: song and sound effect assets
* build: working directory for building and packaging distribution files
* dialogue: text files for all the dialogue
* etc: misc. config files
* lib: third-party Lua libraries
* maps: Lua modules for defining the interactives for each map
* names: text files containing character names
* rake: Ruby Rake modules defining the build tasks
* sources: source asset files not directly used in the game. Doesn't get bundled with builds
* src: core game Lua modules
* tmx: tiled .tmx files defining map layouts
* tmx/tilesets: tilesets used by the .tmx files
* units: images for each unit
