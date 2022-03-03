#!/bin/bash

cd $(dirname "$0")/../..

git clone https://github.com/apollographql/docs-examples.git

cd docs-examples/apollo-server/v3/subscriptions-graphql-ws

npm install
