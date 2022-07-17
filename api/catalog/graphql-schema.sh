#!/bin/bash
set -e

function generate {
  module=$1
  name=$2
  echo "Converting $module to Graphql SDL..."
  mix absinthe.schema.json --schema $module --pretty /tmp/$name-schema.json
  graphql-json-to-sdl /tmp/$name-schema.json $target/$name.graphql
  echo "Created $target/$name.graphql"
}

function verify {
  module=$1
  name=$2
  echo "Verifying $module against current Graphql SDL..."
  mix absinthe.schema.json --schema $module --pretty /tmp/$name-schema.json
  graphql-json-to-sdl /tmp/$name-schema.json /tmp/$name.graphql
  if diff /tmp/$name.graphql $target/$name.graphql; then
    echo "Graphql SDL $name up to date"
  else
    echo "Graphql SDL $name is out to date."
    echo "Run '$0 generate $module $name' to refresh it."
    return 1
  fi
}

target=$(dirname "$0")
command=${1:-generate}
$command $2 $3