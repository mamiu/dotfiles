#!/usr/bin/env fish

# Combination of "mkdir" and "cd"
function mkcd
  # First create a folder for each argument provided
  mkdir -p $argv
  # If the creation of folders was successful change into the first one
  and cd "$argv[1]"
end
