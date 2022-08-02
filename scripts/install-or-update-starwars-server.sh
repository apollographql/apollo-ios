#!/bin/bash

cd $(dirname "$0")/../..

git -C starwars-server pull || git clone https://github.com/apollographql/starwars-server
git -C starwars-server checkout 0.x-legacy-optionals

cd starwars-server

npm install
npm prune
