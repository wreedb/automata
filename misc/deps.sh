#!/usr/bin/env bash

if [[ -d ${PWD}/deps ]]; then
    rm -fr ${PWD}/deps
fi

mkdir -p deps

git clone https://github.com/dlang-community/toml.git --depth=1 --branch=v2.0.1 deps/toml
git -C deps/toml checkout v2.0.1
