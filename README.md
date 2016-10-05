# LuaJIT Heroku Buildpack

This is a buildpack for Heroku that comes bundled with LuaJIT 2.0.4, Luarocks, CMake,
and the moonmint server.

## Usage

```bash
heroku create --buildpack http://github.com/bakpakin/heroku-buildpack-moonmint.git
```

## Summary

This buildpack sets up LuaJIT and Luarocks and configures the relevant environment
variables for easy usage, but makes very few asumptions about your build setup.
It places the necesarry files (luajit, luarocks, cmake) in the `.heroku` directroy
of the generated slug (`/app/.heroku`).

You can also add pre and post install scripts in the root of your project. These should
just be executable files called `heroku-mm-preinstall` and `heroku-mm-postinstall`
respectively. Currently they run sequentially, but eventually there should be an
an install step between that installs dependencies from a rockspec or other listing.
You can use these to install dependencies for now.

## Installing Rocks

Right now create a `heroku-mm-preinstall` exectuable file that installs the needed
rocks. Example:

```bash
#!/usr/bin/env bash

luarocks install dkjson
luarocks install luafilesystem
```

Note that because CMake is bundled, you can install rocks that need CMake to build (like luv).
