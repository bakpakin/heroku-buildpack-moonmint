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
of the generated slug (`/app/.heroku`). It comes with some preinstalled rocks -
moonmint, and openssl, mostly because they are binary rocks and are available only
on the dev server.

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

## Forking this for a more generic (or specialized buildpack)

It is pretty easy to modify this buildpack to pre-install your own rocks, or to
remove the rocks that have been preinstalled. Simply fork this buildpack and
create a simple heroku application using your fork. You can push a dud application first. Then:

```bash
# SSH into a deployed slug.
heroku run bash

# In the slug, remove the packages you don't need and install those you do.
# You can also uninstall cmake from the .heroku directory, or install other things there.
luarocks remove moonmint
luarocks remove openssl
luarocks install luasec

# Now create a tarball of the entire .heroku directory
tar -czvf heroku.tar.gz .heroku

# Upload this file somewhere so you can save it later.
curl --upload-file heroku.tar.gz https://transfer.sh/heroku.tar.gz
# Transfer.sh should give back a url like https://transfer.sh/TN64/heroku.tar.gz

# You're done on the slug.
exit
```

Now cd into the git repository of your forked buildpack. From there, replace the heroku
directory with the one we just compressed and uploaded. You will need to donwload it from
wherever you uploaded it.

```bash
# The actually URL will be different!
wget https://transfer.sh/TN64/heroku.tar.gz
tar -xzvf heroku.tar.gz
rm -rf heroku
mv .heroku heroku
```

Commit and push the changes you made.

## TODO

* Dependency caching for faster builds
