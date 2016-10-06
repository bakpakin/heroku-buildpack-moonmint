# LuaJIT Heroku Buildpack

This is a buildpack for Heroku that comes bundled with LuaJIT 2.0.4, Luarocks, CMake,
and the [moonmint](https://github.com/bakpakin/moonmint) server.

This actually extremely generic, however, and can be easily be used as a genric LuaJIT +
Luarocks buildpack. You could certianly run xavante or some other Lua server pretty
easily with this buildpack.

## Usage

```bash
heroku create --buildpack http://github.com/bakpakin/heroku-buildpack-moonmint.git
```

After creating your app, create a file in your heroku project called server.lua
with the following contents:

```lua
local moonmint = require 'moonmint'
local app = moonmint()

app:get('/', 'Hello, Moonmint on Heroku!')

app:start {
    port = os.getenv 'PORT'
}
```

You now have a functional website and a server. Push to heroku and view your deployed masterpiece.

## Summary

This buildpack sets up LuaJIT and Luarocks and configures the relevant environment
variables for easy usage, but makes very few asumptions about your build setup.
It places the necesarry files (luajit, luarocks, cmake) in the `.heroku` directroy
of the generated slug (`/app/.heroku`).

You can also add pre and post install scripts in the root of your project. These should
just be executable files called `heroku-mm-preinstall` and `heroku-mm-postinstall`
respectively. These run before and after luarocks installs dependencies.

## Installing Rocks

Place a rockspec file (can be called anything with the extension `.rockspec`) in the root
folder of your project. The compile script will use `luarocks build --only-deps $ROCKSPEC`
to install the dependencies listed in that rockspec. The rockspec does not have to contain
valid descriptions of the rest of your project, only the dependencies.

You can also create a `heroku-mm-preinstall` exectuable file that installs the needed
rocks. Example:

```bash
#!/usr/bin/env bash

luarocks install dkjson
luarocks install openssl --server=http://luarocks.org/dev
luarocks build rockspecs/myrockspec.rockspec
```

Note that because CMake is bundled, you can install rocks that need CMake to build (like luv).

## TODO

* Dependency caching for faster builds
