#!/usr/bin/env bash

set -e
set -o pipefail

LOCAL=/app/localbuild

mkdir -p $LOCAL
mkdir -p tmp
pushd tmp

# Create bin and add it to the PATH
mkdir -p bin
mkdir -p include
export PATH=$LOCAL/bin:$PATH

# Get LuaJIT
echo "-----> Fetching LuaJIT..."
wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
tar zxf LuaJIT-2.0.4.tar.gz
pushd LuaJIT-2.0.4
make
make install PREFIX=$LOCAL
popd
rm -rf LuaJIT-2.0.4

# From the luarocks website
echo "-----> Fetching luarocks..."
wget http://luarocks.org/releases/luarocks-2.4.0.tar.gz
tar zxpf luarocks-2.4.0.tar.gz
pushd luarocks-2.4.0
./configure --lua-suffix="jit" --prefix=$LOCAL --with-lua-include=$LOCAL/include/luajit-2.0 --with-lua=$LOCAL/bin
make build
make install
popd

# Get Cmake
echo "-----> Fetching CMake..."
wget https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz
tar zxpf cmake-3.6.2.tar.gz
pushd cmake-3.6.2
./bootstrap --prefix=$LOCAL
make
make install
# Install moonmint
$LOCAL/bin/luarocks install --server=http://luarocks.org/dev moonmint
# Uninstall cmake (only needed for building luv).
make uninstall
popd

# delete tmp
popd
rm -rf tmp

# Now package up the LOCAL directory
cd /app
tar -czxf $LOCAL local.tar.gz

# Upload the file to transfer.sh. Pull it down at modify as need.
# TODO: make this more streamlined.
curl --upload-file ./local.tar.gz https://transfer.sh/heroku-moonmint-buildpack-local.tar.gz
